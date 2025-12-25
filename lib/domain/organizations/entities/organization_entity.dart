import 'package:genesis_workspace/data/organizations/dto/organization_dto.dart';

class OrganizationEntity {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;
  final Set<int> unreadMessages;
  final String? meetingUrl;

  String get imageUrl => icon.contains('https://') ? icon : '$baseUrl$icon';

  OrganizationEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadMessages,
    required this.meetingUrl,
  });

  OrganizationEntity copyWith({Set<int>? unreadMessages, String? meetingUrl}) {
    return OrganizationEntity(
      id: id,
      name: name,
      icon: icon,
      baseUrl: baseUrl,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      meetingUrl: meetingUrl ?? this.meetingUrl,
    );
  }
}

class OrganizationRequestEntity {
  final String name;
  final String icon;
  final String baseUrl;
  final Set<int> unreadMessages;
  final String? meetingUrl;

  OrganizationRequestEntity({
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadMessages,
    this.meetingUrl,
  });

  OrganizationRequestDto toDto() => OrganizationRequestDto(
    name: name,
    icon: icon,
    baseUrl: baseUrl,
    unreadMessages: unreadMessages,
    meetingUrl: meetingUrl,
  );
}
