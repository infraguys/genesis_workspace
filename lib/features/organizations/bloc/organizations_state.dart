part of 'organizations_cubit.dart';

class OrganizationsState {
  final List<OrganizationEntity> organizations;

  const OrganizationsState({required this.organizations});

  const OrganizationsState.initial() : organizations = const [];

  OrganizationsState copyWith({List<OrganizationEntity>? organizations}) {
    return OrganizationsState(organizations: organizations ?? this.organizations);
  }
}
