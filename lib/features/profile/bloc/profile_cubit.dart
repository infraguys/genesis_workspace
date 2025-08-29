import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_own_user_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart';
import 'package:injectable/injectable.dart';

import '../../../services/real_time/real_time_service.dart';

part 'profile_state.dart';

@LazySingleton()
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._realTimeService, this._getOwnUserUseCase, this._updatePresenceUseCase)
    : super(ProfileState(user: null, lastPresenceUpdateId: -1, myPresence: PresenceStatus.idle)) {
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
  }

  final RealTimeService _realTimeService;
  final GetOwnUserUseCase _getOwnUserUseCase;
  final UpdatePresenceUseCase _updatePresenceUseCase;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;

  final player = AudioPlayer();

  Future<void> getOwnUser() async {
    try {
      final response = await _getOwnUserUseCase.call();
      emit(state.copyWith(user: response));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> updatePresence(UpdatePresenceRequestEntity body) async {
    if (state.myPresence != body.status) {
      state.myPresence = body.status;
      try {
        body.lastUpdateId = state.lastPresenceUpdateId;
        final response = await _updatePresenceUseCase.call(body);
        if (response.presenceLastUpdateId != null) {
          state.lastPresenceUpdateId = response.presenceLastUpdateId!;
        }
      } catch (e) {
        inspect(e);
      }
    }
  }

  _onMessageEvents(MessageEventEntity event) {
    if (event.message.senderId != state.user?.userId) {
      player.play(AssetSource(AssetsConstants.audioPop));
    }
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    return super.close();
  }
}
