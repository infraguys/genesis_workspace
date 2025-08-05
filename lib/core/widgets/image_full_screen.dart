import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class ImageFullScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const ImageFullScreen({super.key, required this.imageBytes});

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  late final PhotoViewScaleStateController scaleStateController;

  @override
  void initState() {
    super.initState();
    scaleStateController = PhotoViewScaleStateController();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          onPressed: context.pop,
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => context.pop,
        child: PhotoView(
          scaleStateController: scaleStateController,
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: PhotoViewComputedScale.covered * 2,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.imageBytes.toString()),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          imageProvider: MemoryImage(widget.imageBytes),
        ),
      ),
    );
  }
}
