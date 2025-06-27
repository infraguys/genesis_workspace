import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/event_types.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/get_events_by_queue_id_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  final RegisterQueueUseCase registerQueue = getIt<RegisterQueueUseCase>();
  final GetEventsByQueueIdUseCase getEvents = getIt<GetEventsByQueueIdUseCase>();

  final GetUsersUseCase getUsers = getIt<GetUsersUseCase>();

  final GetSubscribedChannelsUseCase _getSubscribedChannelsUseCase =
      getIt<GetSubscribedChannelsUseCase>();

  Future<void> getSubscribedChannels() async {
    final response = await _getSubscribedChannelsUseCase.call();
    inspect(response);
  }

  Future<void> getLastEvent() async {
    final queueId = await registerQueue.call(
      RegisterQueueRequestBodyEntity(eventTypes: [EventTypes.message]),
    );
    await getEvents.call(
      GetEventsByQueueIdRequestBodyEntity(queueId: queueId.queueId, lastEventId: -1),
    );
  }
}
