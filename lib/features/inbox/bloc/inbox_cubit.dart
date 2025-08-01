import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';

part 'inbox_state.dart';

class InboxCubit extends Cubit<InboxState> {
  InboxCubit() : super(InboxState());

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();

  Future<void> getLastMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      inspect(response);
    } catch (e) {
      inspect(e);
    }
  }
}
