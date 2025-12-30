import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genesis_service_dto.g.dart';

@JsonSerializable()
class GenesisServiceDto {
  @JsonKey(name: 'uuid')
  final String uuid;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'service_url')
  final String serviceUrl;
  @JsonKey(name: 'icon')
  final String icon;

  GenesisServiceDto({
    required this.uuid,
    required this.name,
    required this.description,
    required this.serviceUrl,
    required this.icon,
  });

  factory GenesisServiceDto.fromJson(Map<String, dynamic> json) => _$GenesisServiceDtoFromJson(json);

  GenesisServiceEntity toEntity() => GenesisServiceEntity(
    uuid: uuid,
    name: name,
    description: description,
    serviceUrl: serviceUrl,
    icon: icon,
  );
}

class GenesisServiceRequestDto {
  final String uuid;

  GenesisServiceRequestDto({required this.uuid});
}
