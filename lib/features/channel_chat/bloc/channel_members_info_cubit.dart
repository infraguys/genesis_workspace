import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/users_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:injectable/injectable.dart';

part 'channel_members_info_state.dart';

@injectable
class ChannelMembersInfoCubit extends Cubit<ChannelMembersInfoState> {
  ChannelMembersInfoCubit({required GetUsersUseCase getUsersUseCase}) : _getUsersUseCase = getUsersUseCase, super(_Initial());

  final GetUsersUseCase _getUsersUseCase;

  Future<void> getUsers(Set<int> ids) async {
    emit(ChannelMembersInfoLoadingState());
    final users = await _getUsersUseCase(UsersRequestEntity(userIds: ids.toList()));
    emit(ChannelMembersLoadedState(users));
  }
}
