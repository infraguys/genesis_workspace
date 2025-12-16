import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notifications_state.dart';

@Singleton()
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._realTimeService,
    this._profileCubit,
    this._messengerCubit,
  ) : super(
        NotificationsState(
          user: null,
          mutedChatsIds: {},
        ),
      ) {
    _profileStateSubscription = _profileCubit.stream.listen(_onProfileStateChanged);
    _onProfileStateChanged(_profileCubit.state);
    _messengerStateSubscription = _messengerCubit.stream.listen(_onMessengerStateChanged);
    _onMessengerStateChanged(_messengerCubit.state);
    _messagesEventsSubscription = _realTimeService.messageEventsStream.listen(_onMessageEvents);
  }

  final _player = AudioPlayer();

  late final StreamSubscription<ProfileState> _profileStateSubscription;
  late final StreamSubscription<MessengerState> _messengerStateSubscription;

  final ProfileCubit _profileCubit;
  final MessengerCubit _messengerCubit;
  final MultiPollingService _realTimeService;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;

  void _onProfileStateChanged(ProfileState profileState) {
    final user = profileState.user;
    if (user == null) return;
    if (state.user?.userId == user.userId) return;
    emit(state.copyWith(user: user));
  }

  void _onMessengerStateChanged(MessengerState messengerState) {
    final mutedChatsIds = messengerState.chats.where((chat) => chat.isMuted).map((chat) => chat.id).toSet();
    emit(state.copyWith(mutedChatsIds: mutedChatsIds));
  }

  _onMessageEvents(MessageEventEntity event) async {
    if (event.message.senderId != state.user?.userId && !state.mutedChatsIds.contains(event.message.recipientId)) {
      final prefs = await SharedPreferences.getInstance();
      final selected = prefs.getString(SharedPrefsKeys.notificationSound) ?? AssetsConstants.audioPop;
      _player.play(AssetSource(selected));
    }
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _profileStateSubscription.cancel();
    _messengerStateSubscription.cancel();
    _player.dispose();
    return super.close();
  }
}
