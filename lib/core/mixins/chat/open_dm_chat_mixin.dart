import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
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

  void openChannel(
    BuildContext context, {
    required int channelId,
    String? topicName,
    int? unreadMessagesCount,
  }) {
    final isDesktop = currentSize(context) > ScreenSize.tablet;
    final chat = context.read<MessengerCubit>().state.chats.firstWhere((chat) => chat.streamId == channelId);
    if (isDesktop) {
      context.read<MessengerCubit>().selectChat(chat, selectedTopic: topicName);
    } else {
      if (topicName != null && topicName.isNotEmpty) {
        context.pushNamed(
          Routes.channelChatTopic,
          pathParameters: {
            'chatId': chat.id.toString(),
            'channelId': channelId.toString(),
            'topicName': topicName,
          },
          extra: {'unreadMessagesCount': unreadMessagesCount},
        );
      } else {
        context.pushNamed(
          Routes.channelChat,
          pathParameters: {
            'chatId': chat.id.toString(),
            'channelId': channelId.toString(),
          },
          extra: {'unreadMessagesCount': unreadMessagesCount},
        );
      }
    }
  }
}
