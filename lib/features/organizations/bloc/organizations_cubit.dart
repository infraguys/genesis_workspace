import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/usecases/add_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_settings_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/remove_organization_use_case.dart';
import 'package:genesis_workspace/domain/organizations/usecases/watch_organizations_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/services/organizations/organization_switcher_service.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this._profileCubit,
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
    _messagesFlagsEventsSubscription = _multiPollingService.messageFlagsEventsStream.listen(_onMessageFlagsEvents);
    _profileStateSubscription = _profileCubit.stream.listen(_onProfileStateChanged);
    _onProfileStateChanged(_profileCubit.state);
  }

  final WatchOrganizationsUseCase _watchOrganizationsUseCase;
  final AddOrganizationUseCase _addOrganizationUseCase;
  final GetOrganizationSettingsUseCase _getOrganizationSettingsUseCase;
  final RemoveOrganizationUseCase _removeOrganizationUseCase;
  final OrganizationSwitcherService _organizationSwitcherService;
  final MultiPollingService _multiPollingService;

  final ProfileCubit _profileCubit;

  late final StreamSubscription<List<OrganizationEntity>> _organizationsSubscription;

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messagesFlagsEventsSubscription;
  late final StreamSubscription<ProfileState> _profileStateSubscription;

  void _onProfileStateChanged(ProfileState profileState) {
    final user = profileState.user;
    if (user == null) return;
    if (state.selfUser?.userId == user.userId) return;
    emit(state.copyWith(selfUser: user));
  }

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
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> removeOrganization(int id) async {
    try {
      if (state.organizations.length >= 2) {
        final organization = state.organizations.first;
        await selectOrganization(organization);
      }
      await _removeOrganizationUseCase.call(id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPrefsKeys.selectedOrganizationId);
      await _multiPollingService.closeConnection(id);
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
    if (state.selfUser?.userId == event.message.senderId) {
      return;
    }
    final orgId = event.organizationId;
    List<OrganizationEntity> updatedOrganizations = [...state.organizations];
    final org = updatedOrganizations.firstWhere((element) => element.id == orgId);
    final index = updatedOrganizations.indexOf(org);
    updatedOrganizations[index].unreadMessages.add(event.message.id);
    emit(state.copyWith(organizations: updatedOrganizations));
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    List<OrganizationEntity> updatedOrganizations = [...state.organizations];
    if (event.flag == MessageFlag.read && event.op == UpdateMessageFlagsOp.add) {
      updatedOrganizations.forEach((org) {
        org.unreadMessages.removeAll(event.messages);
      });
    }
    emit(state.copyWith(organizations: updatedOrganizations));
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _organizationsSubscription.cancel();
    _messagesFlagsEventsSubscription.cancel();
    _profileStateSubscription.cancel();
    return super.close();
  }
}
