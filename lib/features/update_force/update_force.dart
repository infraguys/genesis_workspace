import 'package:flutter/material.dart';
import 'package:genesis_workspace/features/update_force/view/update_force_view.dart';

class UpdateForce extends StatelessWidget {
  const UpdateForce({super.key});

  @override
  Widget build(BuildContext context) {
    return UpdateForceView(
      appcastUrlMacOsAndWindows: Uri.parse(''),
      linuxDownloadUrl: Uri.parse(''),
      latestVersion: "1.4.4",
    );
  }
}
