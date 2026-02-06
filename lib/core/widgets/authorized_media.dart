import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// AuthorizedMedia
/// --------------
/// Отображает медиа из `user_uploads` с авторизационными заголовками.
///
/// Сейчас реализовано видео (например `.mp4`):
/// - В чате: превью (первый кадр) + tap to open fullscreen.
/// - В fullscreen: показываем панель управления.
class AuthorizedMedia extends StatelessWidget {
  final String fileUrl;

  const AuthorizedMedia({
    super.key,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Сейчас поддерживаем только видео. Если в будущем добавится аудио/другое —
    // можно расширить здесь по расширению файла или MIME.
    return _AuthorizedVideo(fileUrl: fileUrl);
  }
}

class _AuthorizedVideo extends StatefulWidget {
  final String fileUrl;

  const _AuthorizedVideo({
    required this.fileUrl,
  });

  @override
  State<_AuthorizedVideo> createState() => _AuthorizedVideoState();
}

class _AuthorizedVideoState extends State<_AuthorizedVideo> {
  static const double _fallbackAspectRatio = 16 / 9;
  static const List<DeviceOrientation> _allOrientations = <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  final _videoKey = GlobalKey<VideoState>();

  late final Player _player;
  late final VideoController _controller;

  Object? _initError;
  bool _opening = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _open();
  }

  // @override
  // void didUpdateWidget(covariant _AuthorizedVideo oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.fileUrl.trim() != widget.fileUrl.trim()) {
  //     _open();
  //   }
  // }

  @override
  void dispose() {
    // Safety: if something goes wrong and fullscreen exits without callback,
    // at least don't keep orientation/UI locked after widget disposal.
    _exitMobileFullscreenIfNeeded();
    _player.dispose();
    super.dispose();
  }

  Uri? _resolveUri(String rawUrl) {
    final String trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final Uri? parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;

    if (parsed.hasScheme && parsed.host.isNotEmpty) {
      return parsed;
    }

    if (parsed.hasAuthority && !parsed.hasScheme) {
      final String scheme = Uri.tryParse(AppConstants.baseUrl)?.scheme ?? 'https';
      return Uri.tryParse('$scheme:$trimmed');
    }

    final Uri? baseUri = Uri.tryParse(AppConstants.baseUrl);
    if (baseUri != null && baseUri.hasScheme && baseUri.host.isNotEmpty) {
      return baseUri.resolveUri(parsed);
    }

    return null;
  }

  bool _isHttpScheme(Uri uri) => uri.scheme == 'http' || uri.scheme == 'https';

  int _effectivePort(Uri uri) {
    if (uri.hasPort) return uri.port;
    return uri.scheme == 'https' ? 443 : 80;
  }

  bool _isUserUploadPath(Uri uri) => uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'user_uploads';

  bool _shouldUseAuthorizedHeaders(Uri uri) {
    final Uri? baseUri = Uri.tryParse(AppConstants.baseUrl);
    if (baseUri == null) return false;

    if (!_isHttpScheme(uri) || !_isHttpScheme(baseUri)) return false;

    final bool sameScheme = uri.scheme == baseUri.scheme;
    final bool sameHost = uri.host == baseUri.host;
    final bool samePort = _effectivePort(uri) == _effectivePort(baseUri);

    return sameScheme && sameHost && samePort && _isUserUploadPath(uri);
  }

  Future<Map<String, String>> _buildAuthorizedHeaders() async {
    final storage = getIt<TokenStorage>();
    final headers = <String, String>{};

    final token = await storage.getToken(AppConstants.baseUrl);
    if (token != null && token.contains(':')) {
      final auth = base64Encode(utf8.encode(token));
      headers['Authorization'] = 'Basic $auth';
      headers['Accept'] = 'application/json, text/javascript, */*; q=0.01';
    }

    final cookieParts = <String>['django_language=ru'];

    final sessionId = await storage.getSessionId(AppConstants.baseUrl);
    if (sessionId != null && sessionId.isNotEmpty) {
      cookieParts.add('__Host-sessionid=$sessionId');
    }

    final csrfToken = await storage.getCsrftoken(AppConstants.baseUrl);
    if (csrfToken != null && csrfToken.isNotEmpty) {
      cookieParts.add('__Host-csrftoken=$csrfToken');
      headers['X-CSRFToken'] = csrfToken;
      headers['Referer'] = AppConstants.baseUrl;
    }

    // На Web браузер не позволяет вручную проставлять Cookie/Referer/CSRF
    // заголовки. Оставляем только Authorization (если есть).
    if (!kIsWeb) {
      headers['Cookie'] = cookieParts.join('; ');
    }

    return headers;
  }

  Future<void> _open() async {
    setState(() {
      _opening = true;
      _initError = null;
    });

    final Uri? uri = _resolveUri(widget.fileUrl);
    if (uri == null || !_isHttpScheme(uri)) {
      setState(() {
        _opening = false;
        _initError = const FormatException('Invalid media URL');
      });
      return;
    }

    try {
      final Map<String, String>? headers = _shouldUseAuthorizedHeaders(uri) ? await _buildAuthorizedHeaders() : null;
      if (!mounted) return;

      await _player.setVolume(0.0);
      await _player.open(
        Media(
          uri.toString(),
          httpHeaders: headers,
        ),
        play: false,
      );
      await _player.seek(Duration.zero);

      if (!mounted) return;
      setState(() {
        _opening = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _opening = false;
        _initError = e;
      });
    }
  }

  bool get _isMobile =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _enterMobileFullscreenIfNeeded() async {
    if (!_isMobile) return;
    await Future.wait(<Future<void>>[
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersive,
      ),
    ]);
  }

  Future<void> _exitMobileFullscreenIfNeeded() async {
    if (!_isMobile) return;
    await Future.wait(<Future<void>>[
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      ),
      // На iOS/Android `[]` иногда не снимает лок. Явно возвращаем "всё разрешено".
      SystemChrome.setPreferredOrientations(_allOrientations),
    ]);
  }

  Future<void> _prepareForFullscreenPlayback() async {
    // media_kit volume: 0..100
    await _player.setVolume(70);
    await _player.play();
  }

  Future<void> _restoreAfterFullscreenPlayback() async {
    await _player.pause();
    await _player.setVolume(0.0);
    await _player.seek(Duration.zero);
  }

  Future<void> _enterFullscreen() async {
    if (_opening) return;
    await _prepareForFullscreenPlayback();
    await _videoKey.currentState?.enterFullscreen();
  }

  Future<void> _onEnterFullscreen() async {
    // В fullscreen: скрыть system UI + залочить landscape (для мобильных).
    await _enterMobileFullscreenIfNeeded();
  }

  Future<void> _onExitFullscreen() async {
    await _restoreAfterFullscreenPlayback();
    await _exitMobileFullscreenIfNeeded();
  }

  Future<void> _handleEnterFullscreen() async {
    await _onEnterFullscreen();
  }

  Future<void> _handleExitFullscreen() async {
    await _onExitFullscreen();
  }

  double _aspectRatioFrom(VideoParams? params) {
    final int w = params?.w ?? 1920;
    final int h = params?.h ?? 1080;
    if (w > 0 && h > 0) return w / h;
    return _fallbackAspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrSmaller = currentSize(context) <= .tablet;

    if (_initError != null) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Failed to load video',
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: StreamBuilder<VideoParams>(
          stream: _player.stream.videoParams,
          builder: (context, snapshot) {
            inspect(snapshot);
            final aspectRatio = _aspectRatioFrom(snapshot.data);
            return AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: aspectRatio * 360,
                      minWidth: aspectRatio * 480,
                    ),
                    child: ColoredBox(
                      color: Colors.black,
                      child: Video(
                        key: _videoKey,
                        controller: _controller,
                        fit: BoxFit.fitWidth,
                        aspectRatio: aspectRatio,
                        controls: (state) {
                          final bool showControls = !isTabletOrSmaller || state.isFullscreen();
                          return showControls ? AdaptiveVideoControls(state) : const SizedBox.shrink();
                        },
                        onEnterFullscreen: _handleEnterFullscreen,
                        onExitFullscreen: _handleExitFullscreen,
                      ),
                    ),
                  ),
                  if (_opening)
                    Expanded(
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _opening ? null : _enterFullscreen,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
