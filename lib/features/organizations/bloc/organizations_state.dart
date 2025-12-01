part of 'organizations_cubit.dart';

class OrganizationsState {
  final List<OrganizationEntity> organizations;
  int? selectedOrganizationId;

  OrganizationsState({
    required this.organizations,
    this.selectedOrganizationId,
  });

  OrganizationsState copyWith({
    List<OrganizationEntity>? organizations,
    int? selectedOrganizationId,
  }) {
    return OrganizationsState(
      organizations: organizations ?? this.organizations,
      selectedOrganizationId: selectedOrganizationId ?? this.selectedOrganizationId,
    );
  }
}
