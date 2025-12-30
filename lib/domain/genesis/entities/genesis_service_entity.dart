import 'package:genesis_workspace/data/genesis/dto/genesis_service_dto.dart';

class GenesisServiceEntity {
  final String uuid;
  final String name;
  final String description;
  final String serviceUrl;
  final String icon;
  final bool isFavorite;

  GenesisServiceEntity({
    required this.uuid,
    required this.name,
    required this.description,
    required this.serviceUrl,
    required this.icon,
    this.isFavorite = false,
  });

  factory GenesisServiceEntity.fake() => GenesisServiceEntity(
    uuid: '-1',
    name: 'Service name',
    description: 'Service description',
    serviceUrl: 'https://service.com',
    icon: 'https://icon.com',
  );
}

class GenesisServiceRequestEntity {
  final String uuid;
  GenesisServiceRequestEntity({required this.uuid});

  GenesisServiceRequestDto toDto() => GenesisServiceRequestDto(uuid: uuid);
}
