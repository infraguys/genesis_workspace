part of 'organizations_cubit.dart';

class OrganizationsState {
  final List<OrganizationEntity> organizations;
  int? selectedOrganizationId;
  final UserEntity? selfUser;

  OrganizationsState({
    required this.organizations,
    this.selectedOrganizationId,
    this.selfUser,
  });

  OrganizationsState copyWith({
    List<OrganizationEntity>? organizations,
    int? selectedOrganizationId,
    UserEntity? selfUser,
  }) {
    return OrganizationsState(
      organizations: organizations ?? this.organizations,
      selectedOrganizationId: selectedOrganizationId ?? this.selectedOrganizationId,
      selfUser: selfUser ?? this.selfUser,
    );
  }
}
