import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/in_development_widget.dart';
import 'package:genesis_workspace/features/lk/view/lk_view.dart';

class Lk extends StatelessWidget {
  const Lk({super.key});

  @override
  Widget build(BuildContext context) {
    return (platformInfo.isWeb || platformInfo.isLinux) ? InDevelopmentWidget() : LkView();
  }
}
