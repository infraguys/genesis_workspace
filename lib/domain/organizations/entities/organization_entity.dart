import 'package:genesis_workspace/data/organizations/dto/organization_dto.dart';

class OrganizationEntity {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;
  final Set<int> unreadMessages;

  String get imageUrl => icon.contains('https://') ? icon : '$baseUrl$icon';

  OrganizationEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadMessages,
  });

  OrganizationEntity copyWith({Set<int>? unreadMessages}) {
    return OrganizationEntity(
      id: id,
      name: name,
      icon: icon,
      baseUrl: baseUrl,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }
}

class OrganizationRequestEntity {
  final String name;
  final String icon;
  final String baseUrl;
  final Set<int> unreadMessages;

  OrganizationRequestEntity({
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadMessages,
  });

  OrganizationRequestDto toDto() =>
      OrganizationRequestDto(name: name, icon: icon, baseUrl: baseUrl, unreadMessages: unreadMessages);
}
