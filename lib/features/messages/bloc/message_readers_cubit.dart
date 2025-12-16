import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_message_readers.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:injectable/injectable.dart';

part 'message_readers_state.dart';

@injectable
class MessageReadersCubit extends Cubit<MessageReadersState> {
  MessageReadersCubit({required GetMessageReadersUseCase getMessageReadersUseCase})
    : _getMessageReadersUseCase = getMessageReadersUseCase,
      super(_MessageReadersInitialState());

  final GetMessageReadersUseCase _getMessageReadersUseCase;

  Future<void> getMessageReaders(int messageId) async {
    try {
      emit(MessageReadersLoadingState());
      final users = await _getMessageReadersUseCase(messageId);
      emit(MessageReadersSuccessState(users));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
      rethrow;
    }
  }
}
