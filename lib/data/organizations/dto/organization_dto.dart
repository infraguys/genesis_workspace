import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';

class OrganizationRequestDto {
  final String name;
  final String icon;
  final String baseUrl;
  final int unreadCount;

  OrganizationRequestDto({
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadCount,
  });
}

class OrganizationDto {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;
  final int unreadCount;

  OrganizationDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadCount,
  });

  OrganizationEntity toEntity() => OrganizationEntity(
        id: id,
        name: name,
        icon: icon,
        baseUrl: baseUrl,
        unreadCount: unreadCount,
      );
}
