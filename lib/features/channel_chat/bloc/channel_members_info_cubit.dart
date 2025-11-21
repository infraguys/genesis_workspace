import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/users_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';

part 'channel_members_info_state.dart';

class ChannelMembersInfoCubit extends Cubit<ChannelMembersInfoState> {
  ChannelMembersInfoCubit(this._repository) : super(_Initial());

  final UsersRepository _repository;

  Future<void> getUsers(Set<int> ids) async {
    final useCase = GetUsersUseCase(_repository);

    emit(ChannelMembersInfoLoadingState());
    final users = await useCase(UsersRequestEntity(userIds: ids.toList()));
    emit(ChannelMembersLoadedState(users));
  }
}
