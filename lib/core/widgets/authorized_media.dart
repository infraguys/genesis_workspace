import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
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

  late final Player _player;
  late final VideoController _controller;

  Object? _initError;
  bool _opening = true;
  String? _resolvedUrl;
  Map<String, String>? _headers;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _open();
  }

  @override
  void dispose() {
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

      _resolvedUrl = uri.toString();
      _headers = headers;

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

  Future<void> _openFullscreen(BuildContext context) async {
    final url = _resolvedUrl;
    if (url == null || url.isEmpty) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => _AuthorizedVideoFullScreenPage(
          url: url,
          headers: _headers,
        ),
      ),
    );
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
            final aspectRatio = _aspectRatioFrom(snapshot.data);
            return AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: Colors.black,
                    child: Video(
                      controller: _controller,
                      fit: BoxFit.cover,
                      // В чате контролы не показываем.
                      controls: (_) => const SizedBox.shrink(),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _opening ? null : () => _openFullscreen(context),
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

class _AuthorizedVideoFullScreenPage extends StatefulWidget {
  final String url;
  final Map<String, String>? headers;

  const _AuthorizedVideoFullScreenPage({
    required this.url,
    required this.headers,
  });

  @override
  State<_AuthorizedVideoFullScreenPage> createState() => _AuthorizedVideoFullScreenPageState();
}

class _AuthorizedVideoFullScreenPageState extends State<_AuthorizedVideoFullScreenPage> {
  late final Player _player;
  late final VideoController _controller;

  Object? _error;
  bool _opening = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterImmersive();
    });
    _openAndPlay();
  }

  @override
  void dispose() {
    _exitImmersive();
    _player.dispose();
    super.dispose();
  }

  bool get _isMobile => platformInfo.isMobile;

  Future<void> _enterImmersive() async {
    if (!_isMobile) return;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: const <SystemUiOverlay>[],
    );
  }

  Future<void> _exitImmersive() async {
    if (!_isMobile) return;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _openAndPlay() async {
    try {
      // media_kit volume: 0..100
      await _player.setVolume(70);
      await _player.open(
        Media(
          widget.url,
          httpHeaders: widget.headers,
        ),
        play: true,
      );
      if (!mounted) return;
      setState(() {
        _opening = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _opening = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final controlsTheme = kDefaultMaterialVideoControlsThemeDataFullscreen.copyWith(
      // Мы уже "на весь экран" в отдельном роуте; кнопку fullscreen убираем.
      bottomButtonBar: const <Widget>[
        MaterialPositionIndicator(),
        Spacer(),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MaterialVideoControlsTheme(
            normal: controlsTheme,
            fullscreen: controlsTheme,
            child: Video(
              controller: _controller,
              fit: BoxFit.contain,
              controls: MaterialVideoControls,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
                tooltip: 'Back',
              ),
            ),
          ),
          if (_opening)
            const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          if (_error != null)
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Failed to load video',
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
