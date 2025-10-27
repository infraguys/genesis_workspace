import 'package:genesis_workspace/data/organizations/dto/organization_dto.dart';

class OrganizationEntity {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;

  String get imageUrl => '$baseUrl$icon';

  OrganizationEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
  });
}

class OrganizationRequestEntity {
  final String name;
  final String icon;
  final String baseUrl;

  OrganizationRequestEntity({required this.name, required this.icon, required this.baseUrl});

  OrganizationRequestDto toDto() =>
      OrganizationRequestDto(name: name, icon: icon, baseUrl: baseUrl);
}
