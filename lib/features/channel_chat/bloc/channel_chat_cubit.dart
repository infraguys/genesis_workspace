import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';

part 'channel_chat_state.dart';

class ChannelChatCubit extends Cubit<ChannelChatState> {
  ChannelChatCubit() : super(ChannelChatState());

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();

  Future<void> getChannelMessages(String streamName) async {
    try {
      final response = await _getMessagesUseCase.call(
        MessagesRequestEntity(
          anchor: MessageAnchor.newest(),
          narrow: [MessageNarrowEntity(operator: NarrowOperator.channel, operand: streamName)],
          numBefore: 25,
          numAfter: 0,
        ),
      );
      inspect(response);
    } catch (e) {
      inspect(e);
    }
  }
}
