part of 'organizations_cubit.dart';

class OrganizationsState {
  final List<OrganizationEntity> organizations;
  final int? selectedOrganizationId;

  const OrganizationsState({
    required this.organizations,
    required this.selectedOrganizationId,
  });

  const OrganizationsState.initial()
      : organizations = const [],
        selectedOrganizationId = null;

  OrganizationsState copyWith({
    List<OrganizationEntity>? organizations,
    Object? selectedOrganizationId = _noValue,
  }) {
    return OrganizationsState(
      organizations: organizations ?? this.organizations,
      selectedOrganizationId: identical(selectedOrganizationId, _noValue)
          ? this.selectedOrganizationId
          : selectedOrganizationId as int?,
    );
  }
}

const Object _noValue = Object();
