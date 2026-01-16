import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

mixin OpenDmChatMixin {
  void openChat(
    BuildContext context, {
    required Set<int> membersIds,
    required int chatId,
    int? unreadMessagesCount,
  }) {
    final isDesktop = currentSize(context) > ScreenSize.tablet;

    if (isDesktop) {
      context.read<MessengerCubit>().createEmptyChat(membersIds);
    } else {
      final userIds = membersIds.toList();
      final userIdsString = userIds.join(',');
      context.pushNamed(
        Routes.groupChat,
        pathParameters: {'userIds': userIdsString, 'chatId': chatId.toString()},
        extra: {'unreadMessagesCount': unreadMessagesCount},
      );
    }
  }
}
