import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
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

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterImmersiveIfMobile();
    });
    _openAndPlay();
  }

  @override
  void dispose() {
    _exitImmersiveIfMobile();
    _player.dispose();
    super.dispose();
  }

  bool get _isMobile =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

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

      // media_kit volume: 0..100
      await _player.setVolume(100.0);
      await _player.open(
        Media(
          uri.toString(),
          httpHeaders: headers,
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
      // Мы и так "на весь экран" в отдельном роуте — кнопку fullscreen убираем.
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
