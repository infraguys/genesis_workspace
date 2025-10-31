import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double? size;

  const UserAvatar({super.key, this.avatarUrl, this.size});

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
        radius: size != null ? size! / 2 : null,
        backgroundImage: NetworkImage(fullUrl),
        backgroundColor: Colors.grey[200],
      );
    } else {
      return CircleAvatar(
        radius: size != null ? size! / 2 : null,
        child: Icon(Icons.person),
      );
    }
  }
}
