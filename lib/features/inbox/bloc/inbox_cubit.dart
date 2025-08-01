import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart';

part 'inbox_state.dart';

class InboxCubit extends Cubit<InboxState> {
  InboxCubit() : super(InboxState(dmMessages: [], channelMessages: []));

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = getIt<GetUserByIdUseCase>();

  Future<void> getLastMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);

      final dmMessages = <MessageEntity>[];
      final channelMessages = <MessageEntity>[];

      for (var message in response.messages) {
        if (message.type == MessageType.private) {
          dmMessages.add(message);
        } else if (message.type == MessageType.stream) {
          channelMessages.add(message);
        }
      }

      emit(state.copyWith(dmMessages: dmMessages, channelMessages: channelMessages));
    } catch (e) {
      inspect(e);
    }
  }

  Future<UserEntity> getUserById(int userId) async {
    try {
      return await _getUserByIdUseCase.call(userId);
    } catch (e) {
      rethrow;
    }
  }
}
