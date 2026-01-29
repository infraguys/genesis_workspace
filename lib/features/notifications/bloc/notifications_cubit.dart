import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/domain/channels/entities/user_topic_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/services/notifications/local_notifications_service.dart';
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
    this._prefs,
    this._localNotificationsService,
  ) : super(
        NotificationsState(
          user: null,
          mutedChatsIds: {},
          userTopics: [],
        ),
      ) {
    _profileStateSubscription = _profileCubit.stream.listen(_onProfileStateChanged);
    _onProfileStateChanged(_profileCubit.state);
    _messengerStateSubscription = _messengerCubit.stream.listen(_onMessengerStateChanged);
    _onMessengerStateChanged(_messengerCubit.state);
    _messagesEventsSubscription = _realTimeService.messageEventsStream.listen(_onMessageEvents);
    _messageFlagsEventsSubscription = _realTimeService.messageFlagsEventsStream.listen(_onMessageFlagsEvents);
    _deleteMessageEventsSubscription = _realTimeService.deleteMessageEventsStream.listen(_onDeleteMessageEvents);
  }

  final _player = AudioPlayer();

  late final StreamSubscription<ProfileState> _profileStateSubscription;
  late final StreamSubscription<MessengerState> _messengerStateSubscription;

  final ProfileCubit _profileCubit;
  final MessengerCubit _messengerCubit;
  final MultiPollingService _realTimeService;
  final SharedPreferences _prefs;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsEventsSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageEventsSubscription;
  final LocalNotificationsService _localNotificationsService;

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
    final isChatMuted = state.mutedChatsIds.contains(event.message.recipientId);
    final isOtherMessage = event.message.senderId != state.user?.userId;
    final userTopics = _realTimeService.activeConnections[event.organizationId]?.userTopics;
    final isTopicMuted =
        userTopics?.any((topic) => topic.topicName == event.message.subject && topic.visibilityPolicy == .muted) ??
        false;
    if (isOtherMessage && !isChatMuted && !isTopicMuted) {
      final selected = _prefs.getString(SharedPrefsKeys.notificationSound) ?? AssetsConstants.audioPop;
      _player.play(AssetSource(selected));
      final message = event.message;
      await _localNotificationsService.showNotification(
        message: message,
        organizationId: event.organizationId,
      );
    }
  }

  _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    if (event.flag == MessageFlag.read && event.op == UpdateMessageFlagsOp.add) {
      event.messages.forEach((message) {
        _localNotificationsService.cancelNotification(message);
      });
    }
  }

  _onDeleteMessageEvents(DeleteMessageEventEntity event) {
    _localNotificationsService.cancelNotification(event.messageId);
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _profileStateSubscription.cancel();
    _messengerStateSubscription.cancel();
    _messageFlagsEventsSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    _player.dispose();
    return super.close();
  }
}
