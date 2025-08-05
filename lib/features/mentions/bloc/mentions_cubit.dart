import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';

part 'mentions_state.dart';

class MentionsCubit extends Cubit<MentionsState> {
  MentionsCubit() : super(MentionsState(messages: [], isLoadingMore: false, isAllLoaded: false));

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();

  Future<void> getMessages() async {
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'mentioned')],
        numBefore: 100,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(body);
      state.messages = response.messages;
      emit(state.copyWith(messages: state.messages));
    } catch (e) {
      inspect(e);
    }
  }
}
