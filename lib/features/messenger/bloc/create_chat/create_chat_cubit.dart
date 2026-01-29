import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/channels/usecases/create_channel_use_case.dart';
import 'package:genesis_workspace/domain/common/entities/exception_entity.dart';
import 'package:injectable/injectable.dart';

part 'create_chat_state.dart';

@injectable
class CreateChatCubit extends Cubit<CreateChatState> {
  CreateChatCubit(
    this._createChannelUseCase,
  ) : super(CreateChatInitial());

  final CreateChannelUseCase _createChannelUseCase;

  Future<int?> createChannel({
    required String name,
    required List<int> selectedUsers,
    String? description,
    bool announce = false,
    bool inviteOnly = false,
  }) async {
    emit(CreateChatPending());
    try {
      final body = CreateChannelRequestEntity(
        name: name,
        subscribers: selectedUsers,
        description: description,
        announce: announce,
        inviteOnly: inviteOnly,
      );
      final response = await _createChannelUseCase.call(body);
      emit(CreateChatInitial());
      return response.streamId;
    } on ServerExceptionEntity catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
      if (e.code == 'CHANNEL_ALREADY_EXISTS') {
        emit(CreateChatAlreadyExistError());
      } else {
        emit(CreateChatError(msg: e.msg));
      }
      return null;
    }
  }
}
