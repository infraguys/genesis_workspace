import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/dio_interceptors/csrf_cookie_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/sessionid_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/token_interceptor.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:go_router/go_router.dart';

class AuthorizedImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const AuthorizedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  State<AuthorizedImage> createState() => _AuthorizedImageState();
}

class _AuthorizedImageState extends State<AuthorizedImage> {
  static final Map<String, Uint8List> _cache = {};
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _error = false;

  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _dio.interceptors
      ..add(SessionIdInterceptor(getIt<TokenStorage>()))
      ..add(CsrfCookieInterceptor(getIt<TokenStorage>()))
      ..add(TokenInterceptor(getIt<TokenStorage>()));
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (_cache.containsKey(widget.url)) {
      setState(() {
        _imageBytes = _cache[widget.url];
        _loading = false;
      });
      return;
    }

    try {
      final response = await _dio.get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (!mounted) return;
      final bytes = Uint8List.fromList(response.data!);
      _cache[widget.url] = bytes;
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
    return GestureDetector(
      onTap: () {
        if (_imageBytes != null) {
          context.pushNamed(Routes.imageFullScreen, extra: _imageBytes);
        }
      },
      child: Hero(
        tag: _imageBytes.toString(),
        child: SizedBox(width: widget.width, height: widget.height, child: _buildContent(context)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error || _imageBytes == null) {
      return const Center(child: Icon(Icons.error, color: Colors.red));
    }
    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      filterQuality: FilterQuality.high,
    );
  }
}
