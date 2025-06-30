import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Center(
        child: Column(
          children: [
            Text("CHAT"),
            ElevatedButton(
              onPressed: () async {
                final GetMessagesUseCase _useCase = getIt<GetMessagesUseCase>();
                final body = MessagesRequestEntity(anchor: 0);
                final response = await _useCase.call(body);
                inspect(response);
              },
              child: Text("Get messages"),
            ),
          ],
        ),
      ),
    );
  }
}
