import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

mixin OpenDmChatMixin {
  void openChat(BuildContext context, Set<int> membersIds, {int? unreadMessagesCount}) {
    final isDesktop = currentSize(context) > ScreenSize.lTablet;

    if (isDesktop) {
      context.read<AllChatsCubit>().selectGroupChat(membersIds);
    } else {
      final userIds = membersIds.toList();
      final userIdsString = userIds.join(',');
      context.pushNamed(
        Routes.groupChat,
        pathParameters: {'userIds': userIdsString},
        extra: {'unreadMessagesCount': unreadMessagesCount},
      );
    }
  }
}
