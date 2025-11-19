import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.avatarUrl, this.size}) : _defaultIcons = Icons.person;

  const UserAvatar.group({super.key, this.avatarUrl, this.size}) : _defaultIcons = Icons.groups;

  final String? avatarUrl;
  final double? size;

  final IconData _defaultIcons;

  double? get radius => size != null ? size! / 2 : null;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      var fullUrl = avatarUrl!.startsWith("http") ? avatarUrl! : "${AppConstants.baseUrl}$avatarUrl";

      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(fullUrl),
        backgroundColor: Colors.grey[200],
      );
    }

    return CircleAvatar(
      radius: radius,
      child: Icon(_defaultIcons),
    );
  }
}
