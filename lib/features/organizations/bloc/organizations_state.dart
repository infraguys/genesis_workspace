part of 'organizations_cubit.dart';

class OrganizationsState {
  static const Object _notSpecified = Object();

  final List<OrganizationEntity> organizations;
  final int? selectedOrganizationId;
  final UserEntity? selfUser;

  OrganizationsState({
    required this.organizations,
    this.selectedOrganizationId,
    this.selfUser,
  });

  OrganizationsState copyWith({
    List<OrganizationEntity>? organizations,
    Object? selectedOrganizationId = _notSpecified,
    Object? selfUser = _notSpecified,
  }) {
    return OrganizationsState(
      organizations: organizations ?? this.organizations,
      selectedOrganizationId: identical(selectedOrganizationId, _notSpecified)
          ? this.selectedOrganizationId
          : selectedOrganizationId as int?,
      selfUser: identical(selfUser, _notSpecified) ? this.selfUser : selfUser as UserEntity?,
    );
  }
}
