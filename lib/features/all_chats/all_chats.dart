import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/all_chats_view.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';

class AllChats extends StatelessWidget {
  final int? initialUserId;
  final int? initialChannelId;
  final String? initialTopicName;
  const AllChats({super.key, this.initialUserId, this.initialChannelId, this.initialTopicName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ChannelsCubit>()),
        BlocProvider(create: (context) => getIt<AllChatsCubit>()),
        BlocProvider(create: (context) => getIt<DirectMessagesCubit>()),
      ],
      child: AllChatsView(
        initialUserId: initialUserId,
        initialChannelId: initialChannelId,
        initialTopicName: initialTopicName,
      ),
    );
  }
}
