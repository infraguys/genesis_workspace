import 'package:genesis_workspace/data/organizations/dto/organization_dto.dart';

class OrganizationEntity {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;
  final int unreadCount;

  String get imageUrl => icon.contains('https://') ? icon : '$baseUrl$icon';

  OrganizationEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadCount,
  });

  OrganizationEntity copyWith({int? unreadCount}) {
    return OrganizationEntity(
      id: id,
      name: name,
      icon: icon,
      baseUrl: baseUrl,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class OrganizationRequestEntity {
  final String name;
  final String icon;
  final String baseUrl;
  final int unreadCount;

  OrganizationRequestEntity({
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadCount,
  });

  OrganizationRequestDto toDto() =>
      OrganizationRequestDto(name: name, icon: icon, baseUrl: baseUrl, unreadCount: unreadCount);
}
