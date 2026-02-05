import 'dart:collection';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/dio_interceptors/csrf_cookie_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/sessionid_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/token_interceptor.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AuthorizedImage extends StatefulWidget {
  final String url;
  final String thumbnailUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const AuthorizedImage({
    super.key,
    required this.url,
    required this.thumbnailUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  State<AuthorizedImage> createState() => _AuthorizedImageState();
}

class _AuthorizedImageState extends State<AuthorizedImage> {
  static const int _maxCacheEntries = 50;
  static final Map<String, Uint8List> _cache = LinkedHashMap();
  static final Dio _publicDio = Dio();
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _error = false;

  late final Dio _authorizedDio;

  @override
  void initState() {
    super.initState();
    _authorizedDio = Dio();
    _authorizedDio.interceptors
      ..add(SessionIdInterceptor(getIt<TokenStorage>()))
      ..add(CsrfCookieInterceptor(getIt<TokenStorage>()))
      ..add(TokenInterceptor(getIt<TokenStorage>()));
    _loadImage();
  }

  Uri? _resolveUri(String rawUrl) {
    final String trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    Uri? parsed = Uri.tryParse(trimmed);
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

  bool _shouldUseAuthorizedClient(Uri uri) {
    final Uri? baseUri = Uri.tryParse(AppConstants.baseUrl);
    if (baseUri == null) return false;

    if (!_isHttpScheme(uri) || !_isHttpScheme(baseUri)) return false;

    final bool sameScheme = uri.scheme == baseUri.scheme;
    final bool sameHost = uri.host == baseUri.host;
    final bool samePort = _effectivePort(uri) == _effectivePort(baseUri);

    return sameScheme && sameHost && samePort && _isUserUploadPath(uri);
  }

  void _putInCache(String key, Uint8List value) {
    if (_cache.length >= _maxCacheEntries) {
      final String oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    _cache
      ..remove(key)
      ..[key] = value;
  }

  Future<void> _loadImage() async {
    final Uri? targetUri = _resolveUri(widget.thumbnailUrl);

    if (targetUri == null || !_isHttpScheme(targetUri)) {
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }

    final String cacheKey = targetUri.toString();
    final Uint8List? cached = _cache[cacheKey];
    if (cached != null) {
      // Refresh order to approximate LRU
      _cache.remove(cacheKey);
      _cache[cacheKey] = cached;
      setState(() {
        _imageBytes = cached;
        _loading = false;
      });
      return;
    }

    final bool useAuthorizedClient = _shouldUseAuthorizedClient(targetUri);

    try {
      final response = await (useAuthorizedClient ? _authorizedDio : _publicDio).getUri<List<int>>(
        targetUri,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          extra: useAuthorizedClient ? const {'skipBaseUrlInterceptor': true} : const {},
        ),
      );
      if (!mounted) return;
      final data = response.data;
      if (data == null) {
        throw const FormatException('Empty image response');
      }
      final bytes = Uint8List.fromList(data);
      _putInCache(cacheKey, bytes);
      setState(() {
        _imageBytes = bytes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrSmaller = currentSize(context) <= .tablet;
    final mockHeight = _loading && isTabletOrSmaller;
    return GestureDetector(
      onTap: () {
        if (_imageBytes != null) {
          context.pushNamed(
            Routes.imageFullScreen,
            extra: {
              "imageUrl": widget.url,
              "bytes": _imageBytes,
            },
          );
        }
      },
      child: Hero(
        tag: _imageBytes.toString(),
        child: SizedBox(
          width: widget.width,
          height: mockHeight ? 150 : widget.height,
          child: Builder(
            builder: (BuildContext context) {
              if ((_error || _imageBytes == null) && !_loading) {
                return Container(
                  height: mockHeight ? 150 : widget.height,
                  width: widget.width,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                );
              }
              return Skeletonizer(
                enabled: _loading,
                child: Image.memory(
                  _loading ? Uint8List(1) : (_imageBytes ?? Uint8List(0)),
                  width: widget.width,
                  height: mockHeight ? 150 : widget.height,
                  fit: widget.fit,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: const ColoredBox(color: Colors.white),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
