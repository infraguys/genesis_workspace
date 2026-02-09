import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AuthorizedMedia extends StatelessWidget {
  final String fileUrl;

  const AuthorizedMedia({
    super.key,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthorizedVideoPreview(fileUrl: fileUrl);
  }
}

class _AuthorizedVideoPreview extends StatefulWidget {
  final String fileUrl;

  const _AuthorizedVideoPreview({
    required this.fileUrl,
  });

  @override
  State<_AuthorizedVideoPreview> createState() => _AuthorizedVideoPreviewState();
}

class _AuthorizedVideoPreviewState extends State<_AuthorizedVideoPreview> {
  static const double _fallbackAspectRatio = 16 / 9;

  late final Player _player;
  late final VideoController _controller;

  Object? _initError;
  bool _opening = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _openPreview();
  }

  @override
  void didUpdateWidget(covariant _AuthorizedVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileUrl.trim() != widget.fileUrl.trim()) {
      _openPreview();
    }
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

    if (!kIsWeb) {
      headers['Cookie'] = cookieParts.join('; ');
    }

    return headers;
  }

  Future<void> _openPreview() async {
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

  Future<void> _openFullscreen() async {
    if (_opening) return;
    context.pushNamed(
      Routes.videoFullScreen,
      extra: <String, dynamic>{
        'fileUrl': widget.fileUrl,
      },
    );
  }

  double _aspectRatioFrom(VideoParams? params) {
    final int w = params?.w ?? 0;
    final int h = params?.h ?? 0;
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
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: aspectRatio * 360,
                      minWidth: aspectRatio * 480,
                    ),
                    child: ColoredBox(
                      color: Colors.black,
                      child: Video(
                        controller: _controller,
                        fit: BoxFit.fitWidth,
                        aspectRatio: aspectRatio,
                        controls: NoVideoControls,
                        // onEnterFullscreen: _handleEnterFullscreen,
                        // onExitFullscreen: _handleExitFullscreen,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _opening ? null : _openFullscreen,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
