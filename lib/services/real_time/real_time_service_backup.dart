import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/enums/event_types.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/presence_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/reaction_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/subscription_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_response_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RealTimeServiceBackup {
  RealTimeServiceBackup(this._registerQueueUseCase, this._getEventsByQueueIdUseCase);
  final RegisterQueueUseCase _registerQueueUseCase;
  final GetEventsByQueueIdUseCase _getEventsByQueueIdUseCase;

  int lastEventId = -1;
  String? queueId;

  bool _isPolling = false;

  StreamController<TypingEventEntity> _typingEventsController =
      StreamController<TypingEventEntity>.broadcast();
  Stream<TypingEventEntity> get typingEventsStream => _typingEventsController.stream;

  StreamController<MessageEventEntity> _messagesEventsController =
      StreamController<MessageEventEntity>.broadcast();
  Stream<MessageEventEntity> get messagesEventsStream => _messagesEventsController.stream;

  StreamController<UpdateMessageFlagsEventEntity> _messageFlagsEventsController =
      StreamController<UpdateMessageFlagsEventEntity>.broadcast();
  Stream<UpdateMessageFlagsEventEntity> get messagesFlagsEventsStream =>
      _messageFlagsEventsController.stream;

  StreamController<ReactionEventEntity> _reactionsEventsController =
      StreamController<ReactionEventEntity>.broadcast();
  Stream<ReactionEventEntity> get reactionsEventsStream => _reactionsEventsController.stream;

  StreamController<PresenceEventEntity> _presenceEventsController =
      StreamController<PresenceEventEntity>.broadcast();
  Stream<PresenceEventEntity> get presenceEventsStream => _presenceEventsController.stream;

  StreamController<DeleteMessageEventEntity> _deleteMessageEventsController =
      StreamController<DeleteMessageEventEntity>.broadcast();
  Stream<DeleteMessageEventEntity> get deleteMessageEventsStream =>
      _deleteMessageEventsController.stream;

  StreamController<UpdateMessageEventEntity> _updateMessageEventsController =
      StreamController<UpdateMessageEventEntity>.broadcast();
  Stream<UpdateMessageEventEntity> get updateMessageEventsStream =>
      _updateMessageEventsController.stream;

  StreamController<SubscriptionEventEntity> _subscriptionEventsController =
      StreamController<SubscriptionEventEntity>.broadcast();
  Stream<SubscriptionEventEntity> get subscriptionEventsStream =>
      _subscriptionEventsController.stream;

  Future<RegisterQueueEntity> registerQueue() async {
    try {
      final RegisterQueueEntity response = await _registerQueueUseCase.call(
        RegisterQueueRequestBodyEntity(
          eventTypes: [
            EventTypes.message,
            EventTypes.subscription,
            EventTypes.realm_user,
            EventTypes.update_message_flags,
          ],
        ),
      );
      lastEventId = response.lastEventId;
      queueId = response.queueId;
      return response;
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  Future<EventsByQueueIdResponseEntity> getLastEvent() async {
    if (queueId == null) {
      throw Exception('Queue is not registered');
    }
    try {
      final EventsByQueueIdResponseEntity response = await _getEventsByQueueIdUseCase.call(
        EventsByQueueIdRequestBodyEntity(queueId: queueId!, lastEventId: lastEventId),
      );
      for (var event in response.events) {
        switch (event.type) {
          case EventType.typing:
            _typingEventsController.add(event as TypingEventEntity);
          case EventType.message:
            _messagesEventsController.add(event as MessageEventEntity);
          case EventType.updateMessageFlags:
            _messageFlagsEventsController.add(event as UpdateMessageFlagsEventEntity);
          case EventType.reaction:
            _reactionsEventsController.add(event as ReactionEventEntity);
          case EventType.presence:
            _presenceEventsController.add(event as PresenceEventEntity);
          case EventType.deleteMessage:
            _deleteMessageEventsController.add(event as DeleteMessageEventEntity);
          case EventType.updateMessage:
            _updateMessageEventsController.add(event as UpdateMessageEventEntity);
          case EventType.subscription:
            _subscriptionEventsController.add(event as SubscriptionEventEntity);
          default:
            break;
        }
      }
      lastEventId = response.events.last.id;
      return response;
    } on DioException catch (e) {
      inspect(e);
      if (e.response?.statusCode == 400 && e.response?.data['code'] == 'BAD_EVENT_QUEUE_ID') {
        await registerQueue();
        return await getLastEvent();
      } else {
        rethrow;
      }
    }
  }

  Future<void> startPolling() async {
    if (_messageFlagsEventsController.isClosed) {
      _messageFlagsEventsController = StreamController<UpdateMessageFlagsEventEntity>.broadcast();
    }
    if (_messagesEventsController.isClosed) {
      _messagesEventsController = StreamController<MessageEventEntity>.broadcast();
    }
    if (_typingEventsController.isClosed) {
      _typingEventsController = StreamController<TypingEventEntity>.broadcast();
    }
    if (_reactionsEventsController.isClosed) {
      _reactionsEventsController = StreamController<ReactionEventEntity>.broadcast();
    }
    if (_presenceEventsController.isClosed) {
      _presenceEventsController = StreamController<PresenceEventEntity>.broadcast();
    }
    if (_deleteMessageEventsController.isClosed) {
      _deleteMessageEventsController = StreamController<DeleteMessageEventEntity>.broadcast();
    }
    if (_updateMessageEventsController.isClosed) {
      _updateMessageEventsController = StreamController<UpdateMessageEventEntity>.broadcast();
    }
    if (_subscriptionEventsController.isClosed) {
      _subscriptionEventsController = StreamController<SubscriptionEventEntity>.broadcast();
    }
    if (_isPolling) return;
    try {
      await registerQueue();
      _isPolling = true;

      while (_isPolling) {
        try {
          await getLastEvent();
        } catch (e) {
          inspect(e);
          await Future.delayed(Duration(seconds: 2));
          // _isPolling = false;
        }
      }
    } catch (e) {
      inspect(e);
    }
  }

  /// Остановка цикла
  Future<void> stopPolling() async {
    _isPolling = false;
    _typingEventsController.close();
    _messagesEventsController.close();
    _messageFlagsEventsController.close();
    _reactionsEventsController.close();
    _presenceEventsController.close();
    _deleteMessageEventsController.close();
  }
}
