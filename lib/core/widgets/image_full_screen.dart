import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/dio_interceptors/csrf_cookie_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/sessionid_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/token_interceptor.dart';
import 'package:genesis_workspace/core/shortcuts/close_fullscreen_image_intent.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class ImageFullScreen extends StatefulWidget {
  const ImageFullScreen({super.key, required this.imageUrl, this.bytes});

  final String imageUrl;
  final Uint8List? bytes;

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  late final PhotoViewScaleStateController scaleStateController;
  late final Future _future;
  Uint8List? _imageBytes;
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _dio.interceptors
      ..add(SessionIdInterceptor(getIt<TokenStorage>()))
      ..add(CsrfCookieInterceptor(getIt<TokenStorage>()))
      ..add(TokenInterceptor(getIt<TokenStorage>()));
    _future = _loadImage();
    scaleStateController = PhotoViewScaleStateController();
  }

  Future<void> _loadImage() async {
    if (widget.bytes != null) {
      setState(() {
        _imageBytes = widget.bytes;
      });
      return;
    }
    try {
      final response = await _dio.get<List<int>>(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      setState(() {
        _imageBytes = bytes;
      });
    } catch (e) {
      inspect(e);
      if (!mounted) return;
    }
  }

  @override
  void dispose() {
    scaleStateController.dispose();
    super.dispose();
  }

  void goBack() {
    scaleStateController.scaleState = PhotoViewScaleState.originalSize;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        SingleActivator(.escape): const CloseFullscreenImageIntent(),
      },
      child: Actions(
        actions: {
          CloseFullscreenImageIntent: CloseFullscreenImageAction(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: .fromHeight(76),
              child: Column(
                children: [
                  SizedBox(height: 20.0, width: .infinity),
                  AppBar(
                    backgroundColor: Colors.transparent,
                    systemOverlayStyle: .light,
                    leading: IconButton(
                      onPressed: context.pop,
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.black,
            body: FutureBuilder(
              future: _future,
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == .waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GestureDetector(
                  onTap: context.pop,
                  child: PhotoView(
                    scaleStateController: scaleStateController,
                    minScale: PhotoViewComputedScale.contained * 1,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(tag: _imageBytes.toString()),
                    backgroundDecoration: const BoxDecoration(color: Colors.black),
                    imageProvider: MemoryImage(_imageBytes ?? Uint8List(0)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
