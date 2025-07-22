import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/event_types.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_response_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RealTimeService {
  final RegisterQueueUseCase _registerQueueUseCase = getIt<RegisterQueueUseCase>();
  final GetEventsByQueueIdUseCase _getEventsByQueueIdUseCase = getIt<GetEventsByQueueIdUseCase>();

  int lastEventId = -1;
  String? queueId;

  bool _isPolling = false;

  final _typingEventsController = StreamController<TypingEventEntity>.broadcast();
  Stream<TypingEventEntity> get typingEventsStream => _typingEventsController.stream;

  final _messagesEventsController = StreamController<MessageEventEntity>.broadcast();
  Stream<MessageEventEntity> get messagesEventsStream => _messagesEventsController.stream;

  final _messageFlagsEventsController = StreamController<UpdateMessageFlagsEntity>.broadcast();
  Stream<UpdateMessageFlagsEntity> get messagesFlagsEventsStream =>
      _messageFlagsEventsController.stream;

  Future<RegisterQueueEntity> registerQueue() async {
    try {
      final RegisterQueueEntity response = await _registerQueueUseCase.call(
        RegisterQueueRequestBodyEntity(eventTypes: [EventTypes.message]),
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
      switch (response.events.last.type) {
        case EventType.typing:
          if (response.events.last is TypingEventEntity) {
            _typingEventsController.add(response.events.last as TypingEventEntity);
          }
        case EventType.message:
          if (response.events.last is MessageEventEntity) {
            _messagesEventsController.add(response.events.last as MessageEventEntity);
          }
        case EventType.updateMessageFlags:
          if (response.events.last is UpdateMessageFlagsEntity) {
            _messageFlagsEventsController.add(response.events.last as UpdateMessageFlagsEntity);
          }
        default:
          break;
      }

      // for (var event in response.events) {
      //   switch (event.type) {
      //     case EventType.typing:
      //       if (response.events.last is TypingEventEntity) {
      //         _typingEventsController.add(response.events.last as TypingEventEntity);
      //       }
      //     case EventType.message:
      //       if (response.events.last is MessageEventEntity) {
      //         _messagesEventsController.add(response.events.last as MessageEventEntity);
      //       }
      //     case EventType.updateMessageFlags:
      //       if (response.events.last is UpdateMessageFlagsEntity) {
      //         _messageFlagsEventsController.add(response.events.last as UpdateMessageFlagsEntity);
      //       }
      //     default:
      //       break;
      //   }
      // }
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
    await registerQueue();
    if (_isPolling) return;
    _isPolling = true;

    while (_isPolling) {
      try {
        final lastEvent = await getLastEvent();
        lastEventId = lastEvent.events.last.id;
      } catch (e) {
        inspect(e);
        // Можно подождать немного, чтобы не спамить сервер при ошибках
        await Future.delayed(Duration(seconds: 2));
        // _isPolling = false;
      }
    }
  }

  /// Остановка цикла
  void stopPolling() {
    _isPolling = false;
    _typingEventsController.close();
    _messagesEventsController.close();
  }
}
