import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class DmSearchField extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String)? searchUsers;
  const DmSearchField({super.key, required this.searchController, this.searchUsers});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: searchUsers,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: context.t.search,
        filled: true,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
