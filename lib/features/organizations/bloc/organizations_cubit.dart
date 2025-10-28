import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/usecases/add_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_settings_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/remove_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/watch_organizations_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:injectable/injectable.dart';

part 'organizations_state.dart';

@injectable
class OrganizationsCubit extends Cubit<OrganizationsState> {
  OrganizationsCubit(
    this._watchOrganizationsUseCase,
    this._addOrganizationUseCase,
    this._getOrganizationSettingsUseCase,
    this._removeOrganizationUseCase,
  ) : super(const OrganizationsState.initial()) {
    _organizationsSubscription = _watchOrganizationsUseCase().listen(
      _onOrganizationsUpdated,
      onError: (error, _) => inspect(error),
    );
  }

  final WatchOrganizationsUseCase _watchOrganizationsUseCase;
  final AddOrganizationUseCase _addOrganizationUseCase;
  final GetOrganizationSettingsUseCase _getOrganizationSettingsUseCase;
  final RemoveOrganizationUseCase _removeOrganizationUseCase;

  late final StreamSubscription<List<OrganizationEntity>> _organizationsSubscription;

  void _onOrganizationsUpdated(List<OrganizationEntity> organizations) {
    inspect(organizations);
    emit(state.copyWith(organizations: organizations));
  }

  Future<void> addOrganization(String baseUrl) async {
    try {
      final ServerSettingsEntity serverSettings = await _getOrganizationSettingsUseCase.call(
        baseUrl,
      );
      final OrganizationRequestEntity body = OrganizationRequestEntity(
        name: serverSettings.realmName,
        icon: serverSettings.realmIcon,
        baseUrl: baseUrl,
        unreadCount: 0,
      );
      await _addOrganizationUseCase.call(body);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> removeOrganization(int id) async {
    try {
      await _removeOrganizationUseCase.call(id);
    } catch (e) {
      inspect(e);
    }
  }

  @override
  Future<void> close() {
    _organizationsSubscription.cancel();
    return super.close();
  }
}
