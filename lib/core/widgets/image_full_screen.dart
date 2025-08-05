import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class ImageFullScreen extends StatelessWidget {
  final Uint8List imageBytes;
  const ImageFullScreen({super.key, required this.imageBytes});

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
          heroAttributes: PhotoViewHeroAttributes(tag: imageBytes.toString()),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          imageProvider: MemoryImage(imageBytes),
        ),
      ),
    );
  }
}
