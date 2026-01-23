import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/channels/usecases/create_channel_use_case.dart';
import 'package:injectable/injectable.dart';

part 'create_chat_state.dart';

@injectable
class CreateChatCubit extends Cubit<CreateChatState> {
  CreateChatCubit(
    this._createChannelUseCase,
  ) : super(CreateChatInitial());

  final CreateChannelUseCase _createChannelUseCase;

  Future<void> createChannel({
    required String name,
    required List<int> selectedUsers,
  }) async {
    try {
      final body = CreateChannelRequestEntity(name: name, subscribers: selectedUsers);
      await _createChannelUseCase.call(body);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }
}
