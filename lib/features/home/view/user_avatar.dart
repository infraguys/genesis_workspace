import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;

  const UserAvatar({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      String fullUrl;
      if (avatarUrl!.contains("http")) {
        fullUrl = avatarUrl!;
      } else {
        fullUrl = "${AppConstants.baseUrl}$avatarUrl";
      }
      return CircleAvatar(
        backgroundImage: NetworkImage(fullUrl),
        backgroundColor: Colors.grey[200],
      );
    } else {
      return const CircleAvatar(child: Icon(Icons.person));
    }
  }
}
