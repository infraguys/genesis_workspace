import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/usecases/add_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_settings_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/remove_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/watch_organizations_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:genesis_workspace/services/organizations/organization_switcher_service.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';

part 'organizations_state.dart';

@injectable
class OrganizationsCubit extends Cubit<OrganizationsState> {
  OrganizationsCubit(
    this._watchOrganizationsUseCase,
    this._addOrganizationUseCase,
    this._getOrganizationSettingsUseCase,
    this._removeOrganizationUseCase,
    this._organizationSwitcherService,
    this._multiPollingService,
  ) : super(
        OrganizationsState(
          organizations: [],
          selectedOrganizationId: null,
        ),
      ) {
    _organizationsSubscription = _watchOrganizationsUseCase().listen(
      _onOrganizationsUpdated,
      onError: (error, _) => inspect(error),
    );
    _messagesEventsSubscription = _multiPollingService.messageEventsStream.listen(_onMessageEvents);
  }

  final WatchOrganizationsUseCase _watchOrganizationsUseCase;
  final AddOrganizationUseCase _addOrganizationUseCase;
  final GetOrganizationSettingsUseCase _getOrganizationSettingsUseCase;
  final RemoveOrganizationUseCase _removeOrganizationUseCase;
  final OrganizationSwitcherService _organizationSwitcherService;
  final MultiPollingService _multiPollingService;

  late final StreamSubscription<List<OrganizationEntity>> _organizationsSubscription;

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;

  void _onOrganizationsUpdated(List<OrganizationEntity> organizations) {
    final int? persistedSelection = state.selectedOrganizationId ?? AppConstants.selectedOrganizationId;
    int? nextSelection = persistedSelection;

    if (nextSelection != null && organizations.every((element) => element.id != nextSelection)) {
      nextSelection = organizations.isNotEmpty ? organizations.first.id : null;
    }

    emit(state.copyWith(organizations: organizations, selectedOrganizationId: nextSelection));
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
        unreadMessages: {},
      );
      final organization = await _addOrganizationUseCase.call(body);
      await _multiPollingService.addConnection(organization.id, organization.baseUrl);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> removeOrganization(int id) async {
    try {
      await _removeOrganizationUseCase.call(id);
      await _multiPollingService.closeConnection(id);
      if (state.organizations.isNotEmpty) {
        final organization = state.organizations.first;
        await selectOrganization(organization);
      }
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> selectOrganization(OrganizationEntity organization) async {
    if (state.selectedOrganizationId == organization.id) return;
    final int? previousSelection = state.selectedOrganizationId;
    emit(state.copyWith(selectedOrganizationId: organization.id));
    try {
      await _organizationSwitcherService.selectOrganization(organization);
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(selectedOrganizationId: previousSelection));
    }
  }

  void _onMessageEvents(MessageEventEntity event) {
    final orgId = event.organizationId;
    inspect(event);
    List<OrganizationEntity> updatedOrganizations = [...state.organizations];
    final org = updatedOrganizations.firstWhere((element) => element.id == orgId);
    final index = updatedOrganizations.indexOf(org);
    updatedOrganizations[index].unreadMessages.add(event.message.id);
    emit(state.copyWith(organizations: updatedOrganizations));
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _organizationsSubscription.cancel();
    return super.close();
  }
}
