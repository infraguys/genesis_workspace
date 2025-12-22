import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:genesis_workspace/core/config/constants.dart';

class LkView extends StatefulWidget {
  const LkView({super.key});

  @override
  State<LkView> createState() => _LkViewState();
}

class _LkViewState extends State<LkView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri.uri(
              Uri.parse(AppConstants.lkUrl),
            ),
          ),
        ),
      ),
    );
  }
}
