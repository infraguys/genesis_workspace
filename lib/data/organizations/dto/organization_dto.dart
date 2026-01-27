import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';

class OrganizationRequestDto {
  final String name;
  final String icon;
  final String baseUrl;
  final Set<int> unreadMessages;
  final String? meetingUrl;
  final int? streamNameMaxLength;
  final int? streamDescriptionMaxLength;

  OrganizationRequestDto({
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadMessages,
    this.meetingUrl,
    this.streamNameMaxLength,
    this.streamDescriptionMaxLength,
  });
}

class OrganizationDto {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;
  final Set<int> unreadMessages;
  final String? meetingUrl;
  final int? streamNameMaxLength;
  final int? streamDescriptionMaxLength;

  OrganizationDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadMessages,
    this.meetingUrl,
    this.streamNameMaxLength,
    this.streamDescriptionMaxLength,
  });

  OrganizationEntity toEntity() {
    String refactoredBaseUrl = baseUrl;
    if (baseUrl.endsWith("/")) {
      refactoredBaseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    return OrganizationEntity(
      id: id,
      name: name,
      icon: icon,
      baseUrl: refactoredBaseUrl,
      unreadMessages: unreadMessages,
      meetingUrl: meetingUrl,
      streamNameMaxLength: streamNameMaxLength,
      streamDescriptionMaxLength: streamDescriptionMaxLength,
    );
  }
}
