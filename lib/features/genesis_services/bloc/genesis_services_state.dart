part of 'genesis_services_cubit.dart';

@immutable
sealed class GenesisServicesState {}

final class GenesisServicesInitial extends GenesisServicesState {}

final class GenesisServicesLoading extends GenesisServicesState {}

final class GenesisServicesError extends GenesisServicesState {}

final class GenesisServicesLoaded extends GenesisServicesState {
  final List<GenesisServiceEntity> services;
  GenesisServicesLoaded({required this.services});
}
