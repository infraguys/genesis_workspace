// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  email: json['email'] as String,
  userId: (json['user_id'] as num).toInt(),
  avatarVersion: (json['avatar_version'] as num).toInt(),
  isAdmin: json['is_admin'] as bool,
  isOwner: json['is_owner'] as bool,
  isGuest: json['is_guest'] as bool,
  role: (json['role'] as num).toInt(),
  isBot: json['is_bot'] as bool,
  fullName: json['full_name'] as String,
  timezone: json['timezone'] as String,
  isActive: json['is_active'] as bool,
  dateJoined: json['date_joined'] as String,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'email': instance.email,
  'user_id': instance.userId,
  'avatar_version': instance.avatarVersion,
  'is_admin': instance.isAdmin,
  'is_owner': instance.isOwner,
  'is_guest': instance.isGuest,
  'role': instance.role,
  'is_bot': instance.isBot,
  'full_name': instance.fullName,
  'timezone': instance.timezone,
  'is_active': instance.isActive,
  'date_joined': instance.dateJoined,
  'avatar_url': instance.avatarUrl,
};
