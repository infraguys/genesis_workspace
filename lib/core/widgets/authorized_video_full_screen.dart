import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/shortcuts/close_fullscreen_video_intent.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AuthorizedVideoFullScreenPage extends StatefulWidget {
  final String fileUrl;

  const AuthorizedVideoFullScreenPage({
    super.key,
    required this.fileUrl,
  });

  @override
  State<AuthorizedVideoFullScreenPage> createState() => _AuthorizedVideoFullScreenPageState();
}

class _AuthorizedVideoFullScreenPageState extends State<AuthorizedVideoFullScreenPage> {
  late final Player _player;
  late final VideoController _controller;

  Object? _error;
  bool _opening = true;
  final List<StreamSubscription<dynamic>> _debugSubs = [];
  bool _forcedAudioTrack = false;
  bool _showAudioHint = false;

  @override
  void initState() {
    super.initState();
    _player = getIt<Player>();
    _controller = getIt<VideoController>();
    if (kDebugMode) {
      _attachDebugListeners();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterImmersiveIfMobile();
    });
    _openAndPlay();
  }

  @override
  void dispose() {
    for (final sub in _debugSubs) {
      sub.cancel();
    }
    _exitImmersiveIfMobile();
    unawaited(_player.stop());
    super.dispose();
  }

  void _attachDebugListeners() {
    _debugSubs.add(_player.stream.audioDevices.listen((devices) {
      debugPrint('Audio devices: $devices');
    }));
    _debugSubs.add(_player.stream.audioDevice.listen((device) {
      debugPrint('Audio device selected: $device');
    }));
    _debugSubs.add(_player.stream.audioParams.listen((params) {
      debugPrint('Audio params: $params');
    }));
    _debugSubs.add(_player.stream.tracks.listen((tracks) {
      debugPrint('Audio tracks: ${tracks.audio}');
      if (_forcedAudioTrack) return;
      final real = tracks.audio.where((t) => t.id != 'auto' && t.id != 'no').toList();
      if (real.isNotEmpty) {
        _forcedAudioTrack = true;
        unawaited(_player.setAudioTrack(real.first));
      }
    }));
    _debugSubs.add(_player.stream.track.listen((track) {
      debugPrint('Selected track: $track');
    }));
    _debugSubs.add(_player.stream.error.listen((err) {
      debugPrint('Player error: $err');
    }));
    _debugSubs.add(_player.stream.log.listen((log) {
      debugPrint('MPV ${log.level} ${log.prefix}: ${log.text}');
    }));
  }

  bool get _isMobile =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  bool get _isLinuxDesktop => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  Future<void> _enterImmersiveIfMobile() async {
    if (!_isMobile) return;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: const <SystemUiOverlay>[],
    );
  }

  Future<void> _exitImmersiveIfMobile() async {
    if (!_isMobile) return;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
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
    // return true;
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

    if (!kIsWeb) {
      headers['Cookie'] = cookieParts.join('; ');
    }

    return headers;
  }

  Future<void> _openAndPlay() async {
    try {
      final Uri? uri = _resolveUri(widget.fileUrl);
      if (uri == null || !_isHttpScheme(uri)) {
        throw const FormatException('Invalid media URL');
      }

      final Map<String, String>? headers = _shouldUseAuthorizedHeaders(uri) ? await _buildAuthorizedHeaders() : null;

      await _player.open(
        Media(
          uri.toString(),
          httpHeaders: headers,
        ),
        play: true,
      );
      await _player.setAudioDevice(AudioDevice.auto());
      // media_kit volume: 0..100
      await _player.setVolume(100);

      if (!mounted) return;
      setState(() {
        _opening = false;
        _showAudioHint = _isLinuxDesktop;
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
      // Мы и так "на весь экран" в отдельном роуте — кнопку fullscreen убираем.
      bottomButtonBar: const <Widget>[
        MaterialPositionIndicator(),
        Spacer(),
      ],
    );

    return Shortcuts(
      shortcuts: {
        SingleActivator(.escape): const CloseFullscreenVideoIntent(),
      },
      child: Actions(
        actions: {
          CloseFullscreenVideoIntent: CloseFullscreenVideoAction(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
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
                    controls: AdaptiveVideoControls,
                    // При смене ориентации/метрик не хотим автопауз.
                    pauseUponEnteringBackgroundMode: false,
                    resumeUponEnteringForegroundMode: true,
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.white,
                      tooltip: 'Back',
                    ),
                  ),
                ),
                if (_showAudioHint)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: SafeArea(
                      minimum: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Если нет звука, проверьте системный микшер (PipeWire/PulseAudio): '
                                'приложение может быть приглушено или направлено на другой выход.',
                                style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showAudioHint = false;
                                });
                              },
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              tooltip: 'Close',
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
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
          ),
        ),
      ),
    );
  }
}
