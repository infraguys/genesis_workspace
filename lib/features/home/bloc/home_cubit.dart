import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final _realTimeService = getIt<RealTimeService>();

  HomeCubit() : super(HomeState(users: [], isUsersPending: false, typingUsers: [])) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
  }

  final RegisterQueueUseCase registerQueue = getIt<RegisterQueueUseCase>();
  final GetEventsByQueueIdUseCase getEvents = getIt<GetEventsByQueueIdUseCase>();

  final GetUsersUseCase _getUsersUseCase = getIt<GetUsersUseCase>();

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;

  void _onTypingEvents(TypingEventEntity event) {
    final isWriting = event.op == 'start';
    final senderId = event.sender.userId;

    if (isWriting) {
      state.typingUsers.add(senderId);
    } else {
      state.typingUsers.remove(senderId);
    }
    emit(state.copyWith(typingUsers: state.typingUsers));
  }

  getUsers() async {
    try {
      final response = await _getUsersUseCase.call();
      inspect(response);
      state.users = response;
      emit(state.copyWith(users: state.users));
    } catch (e) {
      inspect(e);
    }
  }
}
