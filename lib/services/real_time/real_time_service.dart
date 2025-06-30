import 'dart:async';
import 'dart:developer';

import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/event_types.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
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
          _typingEventsController.add(response.events.last as TypingEventEntity);
        default:
          break;
      }
      return response;
    } catch (e) {
      rethrow;
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
  }
}
