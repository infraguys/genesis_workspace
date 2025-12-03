import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/enums/event_types.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';
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
import 'package:genesis_workspace/domain/real_time_events/usecases/delete_queue_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';

class RealTimeConnection {
  final int organizationId;
  final String baseUrl;
  final RegisterQueueUseCase _registerQueueUseCase;
  final GetEventsByQueueIdUseCase _getEventsByQueueIdUseCase;
  final DeleteQueueUseCase _deleteQueueUseCase;

  final Duration _initialRetryDelay;
  final Duration _maxRetryDelay;

  String? _queueId;
  int _lastEventId = -1;
  bool _isActive = false;
  Future<void>? _pollingTask;

  bool get isActive => _isActive;

  RealTimeConnection({
    required this.organizationId,
    required this.baseUrl,
    required RegisterQueueUseCase registerQueueUseCase,
    required GetEventsByQueueIdUseCase getEventsByQueueIdUseCase,
    required DeleteQueueUseCase deleteQueueUseCase,
    Duration initialRetryDelay = const Duration(seconds: 1),
    Duration maxRetryDelay = const Duration(seconds: 20),
  }) : _registerQueueUseCase = registerQueueUseCase,
       _getEventsByQueueIdUseCase = getEventsByQueueIdUseCase,
       _deleteQueueUseCase = deleteQueueUseCase,
       _initialRetryDelay = initialRetryDelay,
       _maxRetryDelay = maxRetryDelay;

  final StreamController<TypingEventEntity> _typingEventsController = StreamController<TypingEventEntity>.broadcast();
  final StreamController<MessageEventEntity> _messageEventsController =
      StreamController<MessageEventEntity>.broadcast();
  final StreamController<UpdateMessageFlagsEventEntity> _messageFlagsEventsController =
      StreamController<UpdateMessageFlagsEventEntity>.broadcast();
  final StreamController<ReactionEventEntity> _reactionEventsController =
      StreamController<ReactionEventEntity>.broadcast();
  final StreamController<PresenceEventEntity> _presenceEventsController =
      StreamController<PresenceEventEntity>.broadcast();
  final StreamController<DeleteMessageEventEntity> _deleteMessageEventsController =
      StreamController<DeleteMessageEventEntity>.broadcast();
  final StreamController<UpdateMessageEventEntity> _updateMessageEventsController =
      StreamController<UpdateMessageEventEntity>.broadcast();
  final StreamController<SubscriptionEventEntity> _subscriptionEventsController =
      StreamController<SubscriptionEventEntity>.broadcast();

  Stream<TypingEventEntity> get typingEventsStream => _typingEventsController.stream;

  Stream<MessageEventEntity> get messageEventsStream => _messageEventsController.stream;

  Stream<UpdateMessageFlagsEventEntity> get messageFlagsEventsStream => _messageFlagsEventsController.stream;

  Stream<ReactionEventEntity> get reactionEventsStream => _reactionEventsController.stream;

  Stream<PresenceEventEntity> get presenceEventsStream => _presenceEventsController.stream;

  Stream<DeleteMessageEventEntity> get deleteMessageEventsStream => _deleteMessageEventsController.stream;

  Stream<UpdateMessageEventEntity> get updateMessageEventsStream => _updateMessageEventsController.stream;

  Stream<SubscriptionEventEntity> get subscriptionEventsStream => _subscriptionEventsController.stream;

  Future<void> start() async {
    if (_isActive) return;
    try {
      await _registerQueue();
      _isActive = true;
      _pollingTask = _pollLoop();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> stop() async {
    _isActive = false;
    if (_queueId != null) {
      await _deleteQueueUseCase.call(_queueId);
    }
    await _pollingTask;
    _queueId = null;
    await _closeControllers();
  }

  Future<bool> checkConnection() async {
    if (_isActive && _queueId != null) {
      try {
        final body = EventsByQueueIdRequestBodyEntity(queueId: _queueId!, lastEventId: _lastEventId, dontBlock: true);
        final response = await _getEventsByQueueIdUseCase.call(body);
        if (response.result == 'success') {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> _closeControllers() async {
    await Future.wait([
      _typingEventsController.close(),
      _messageEventsController.close(),
      _messageFlagsEventsController.close(),
      _reactionEventsController.close(),
      _presenceEventsController.close(),
      _deleteMessageEventsController.close(),
      _updateMessageEventsController.close(),
      _subscriptionEventsController.close(),
    ]);
  }

  Future<void> _registerQueue() async {
    try {
      final RegisterQueueEntity registerQueueEntity = await _registerQueueUseCase.call(
        RegisterQueueRequestBodyEntity(eventTypes: [EventTypes.message, EventTypes.realm_user]),
      );
      _queueId = registerQueueEntity.queueId;
      _lastEventId = registerQueueEntity.lastEventId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _pollLoop() async {
    Duration retryDelay = _initialRetryDelay;
    final Random random = Random();

    while (_isActive) {
      try {
        await _fetchAndDispatch();
        retryDelay = _initialRetryDelay;
      } on DioException catch (error) {
        final bool isBadQueueId =
            error.response?.statusCode == 400 && error.response?.data?['code'] == 'BAD_EVENT_QUEUE_ID';
        if (isBadQueueId) {
          await _registerQueue();
          continue;
        }
        await _sleepWithJitter(retryDelay, random);
        retryDelay = _nextDelay(retryDelay);
      } catch (_) {
        await _sleepWithJitter(retryDelay, random);
        retryDelay = _nextDelay(retryDelay);
      }
    }
  }

  Future<void> _fetchAndDispatch() async {
    try {
      if (_queueId == null) {
        await _registerQueue();
      }
      final String queueIdValue = _queueId!;
      final EventsByQueueIdResponseEntity response = await _getEventsByQueueIdUseCase.call(
        EventsByQueueIdRequestBodyEntity(queueId: queueIdValue, lastEventId: _lastEventId),
      );

      if (response.queueId != null) {
        _queueId = response.queueId;
      }

      if (response.events.isEmpty) return;

      for (final EventEntity event in response.events) {
        event.organizationId = organizationId;
        switch (event.type) {
          case EventType.typing:
            _typingEventsController.add(event as TypingEventEntity);
            break;
          case EventType.message:
            _messageEventsController.add(event as MessageEventEntity);
            break;
          case EventType.updateMessageFlags:
            _messageFlagsEventsController.add(event as UpdateMessageFlagsEventEntity);
            break;
          case EventType.reaction:
            _reactionEventsController.add(event as ReactionEventEntity);
            break;
          case EventType.presence:
            _presenceEventsController.add(event as PresenceEventEntity);
            break;
          case EventType.deleteMessage:
            _deleteMessageEventsController.add(event as DeleteMessageEventEntity);
            break;
          case EventType.updateMessage:
            _updateMessageEventsController.add(event as UpdateMessageEventEntity);
            break;
          case EventType.subscription:
            _subscriptionEventsController.add(event as SubscriptionEventEntity);
            break;
          default:
            break;
        }
      }

      _lastEventId = response.events.last.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sleepWithJitter(Duration baseDelay, Random random) async {
    final int jitterMillis = random.nextInt(300);
    final Duration delay = baseDelay + Duration(milliseconds: jitterMillis);
    await Future.delayed(delay);
  }

  Duration _nextDelay(Duration current) {
    final Duration doubled = Duration(milliseconds: current.inMilliseconds * 2);
    if (doubled > _maxRetryDelay) return _maxRetryDelay;
    return doubled;
  }
}
