import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState(messages: []));

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();

  Future<void> getMessages(int userId) async {
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.oldest,
        narrow: [
          MessageNarrowEntity(operator: NarrowOperator.dm, operand: [userId]),
        ],
        numBefore: 100,
        numAfter: 100,
      );
      final response = await _getMessagesUseCase.call(body);
      inspect(response);
      state.messages = response.messages;
      emit(state.copyWith(messages: state.messages));
    } catch (e) {
      inspect(e);
    }
  }
}
