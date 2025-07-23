import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.profile)),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final _getMessagesUseCase = getIt<GetMessagesUseCase>();
              final response = await _getMessagesUseCase.call(
                MessagesRequestEntity(
                  anchor: MessageAnchor.firstUnread(),
                  numBefore: 1000,
                  numAfter: 0,
                ),
              );
              List<MessageEntity> unreadMessages = response.messages.where((message) {
                if (message.flags != null) {
                  return !message.flags!.contains('read');
                } else {
                  return true;
                }
              }).toList();
              inspect(unreadMessages);
            },
            child: Text("Get messages"),
          ),
          ElevatedButton(
            onPressed: () {
              LocaleSettings.setLocale(AppLocale.ru);
            },
            child: Text("Set ru"),
          ),
          ElevatedButton(
            onPressed: () {
              LocaleSettings.setLocale(AppLocale.en);
            },
            child: Text("Set en"),
          ),
        ],
      ),
    );
  }
}
