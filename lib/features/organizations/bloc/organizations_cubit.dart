import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/usecases/add_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/watch_organizations_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_server_settings_use_case.dart';
import 'package:injectable/injectable.dart';

part 'organizations_state.dart';

@injectable
class OrganizationsCubit extends Cubit<OrganizationsState> {
  OrganizationsCubit(
    this._watchOrganizationsUseCase,
    this._addOrganizationUseCase,
    this._getServerSettingsUseCase,
  ) : super(const OrganizationsState.initial()) {
    _organizationsSubscription = _watchOrganizationsUseCase().listen(
      _onOrganizationsUpdated,
      onError: (error, _) => inspect(error),
    );
  }

  final WatchOrganizationsUseCase _watchOrganizationsUseCase;
  final AddOrganizationUseCase _addOrganizationUseCase;
  final GetServerSettingsUseCase _getServerSettingsUseCase;

  late final StreamSubscription<List<OrganizationEntity>> _organizationsSubscription;

  void _onOrganizationsUpdated(List<OrganizationEntity> organizations) {
    inspect(organizations);
    emit(state.copyWith(organizations: organizations));
  }

  Future<void> addOrganization(String baseUrl) async {
    try {
      final serverSettings = await _getServerSettingsUseCase.call(serverUrl: baseUrl);
      final organizationRequest = OrganizationRequestEntity(
        name: serverSettings.realmName,
        icon: serverSettings.realmIcon,
        baseUrl: baseUrl,
        unreadCount: 0,
      );
      final id = await _addOrganizationUseCase.call(organizationRequest);
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
