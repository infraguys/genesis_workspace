import 'package:flutter/material.dart';
import 'package:genesis_workspace/features/paste_base_url/view/paste_base_url_view.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class PasteBaseUrl extends StatelessWidget {
  const PasteBaseUrl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.auth.pasteBaseUrlHere)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PasteBaseUrlView(),
          ),
        ),
      ),
    );
  }
}
