import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';

class OrganizationRequestDto {
  final String name;
  final String icon;
  final String baseUrl;

  OrganizationRequestDto({required this.name, required this.icon, required this.baseUrl});
}

class OrganizationDto {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;

  OrganizationDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
  });

  OrganizationEntity toEntity() =>
      OrganizationEntity(id: id, name: name, icon: icon, baseUrl: baseUrl);
}
