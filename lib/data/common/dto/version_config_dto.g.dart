// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionConfigDto _$VersionConfigDtoFromJson(Map<String, dynamic> json) =>
    VersionConfigDto(
      spec: SpecDto.fromJson(json['spec'] as Map<String, dynamic>),
      policy: PolicyDto.fromJson(json['policy'] as Map<String, dynamic>),
      latest: LatestDto.fromJson(json['latest'] as Map<String, dynamic>),
      versions: VersionsDto.fromJson(json['versions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VersionConfigDtoToJson(VersionConfigDto instance) =>
    <String, dynamic>{
      'spec': instance.spec.toJson(),
      'policy': instance.policy.toJson(),
      'latest': instance.latest.toJson(),
      'versions': instance.versions.toJson(),
    };

SpecDto _$SpecDtoFromJson(Map<String, dynamic> json) =>
    SpecDto(schemaVersion: json['schema_version'] as String);

Map<String, dynamic> _$SpecDtoToJson(SpecDto instance) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
};

PolicyDto _$PolicyDtoFromJson(Map<String, dynamic> json) => PolicyDto(
  update: UpdatePolicyDto.fromJson(json['update'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PolicyDtoToJson(PolicyDto instance) => <String, dynamic>{
  'update': instance.update.toJson(),
};

UpdatePolicyDto _$UpdatePolicyDtoFromJson(Map<String, dynamic> json) =>
    UpdatePolicyDto(
      minVersion: MinVersionDto.fromJson(
        json['min_version'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UpdatePolicyDtoToJson(UpdatePolicyDto instance) =>
    <String, dynamic>{'min_version': instance.minVersion.toJson()};

MinVersionDto _$MinVersionDtoFromJson(Map<String, dynamic> json) =>
    MinVersionDto(
      minStable: json['min_stable'] as String,
      minShortStable: json['min_short_stable'] as String,
      minDev: json['min_dev'] as String,
      minShortDev: json['min_short_dev'] as String,
    );

Map<String, dynamic> _$MinVersionDtoToJson(MinVersionDto instance) =>
    <String, dynamic>{
      'min_stable': instance.minStable,
      'min_short_stable': instance.minShortStable,
      'min_dev': instance.minDev,
      'min_short_dev': instance.minShortDev,
    };

LatestDto _$LatestDtoFromJson(Map<String, dynamic> json) => LatestDto(
  stable: ReleaseChannelDto.fromJson(json['stable'] as Map<String, dynamic>),
  dev: ReleaseChannelDto.fromJson(json['dev'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LatestDtoToJson(LatestDto instance) => <String, dynamic>{
  'stable': instance.stable.toJson(),
  'dev': instance.dev.toJson(),
};

VersionsDto _$VersionsDtoFromJson(Map<String, dynamic> json) => VersionsDto(
  stable: (json['stable'] as List<dynamic>)
      .map((e) => VersionEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  dev: (json['dev'] as List<dynamic>)
      .map((e) => VersionEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VersionsDtoToJson(VersionsDto instance) =>
    <String, dynamic>{
      'stable': instance.stable.map((e) => e.toJson()).toList(),
      'dev': instance.dev.map((e) => e.toJson()).toList(),
    };

ReleaseChannelDto _$ReleaseChannelDtoFromJson(Map<String, dynamic> json) =>
    ReleaseChannelDto(
      version: json['version'] as String,
      shortVersion: json['short_version'] as String,
      linux: PlatformDto.fromJson(json['linux'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReleaseChannelDtoToJson(ReleaseChannelDto instance) =>
    <String, dynamic>{
      'version': instance.version,
      'short_version': instance.shortVersion,
      'linux': instance.linux.toJson(),
    };

VersionEntryDto _$VersionEntryDtoFromJson(Map<String, dynamic> json) =>
    VersionEntryDto(
      version: json['version'] as String,
      shortVersion: json['short_version'] as String,
      linux: PlatformDto.fromJson(json['linux'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VersionEntryDtoToJson(VersionEntryDto instance) =>
    <String, dynamic>{
      'version': instance.version,
      'short_version': instance.shortVersion,
      'linux': instance.linux.toJson(),
    };

PlatformDto _$PlatformDtoFromJson(Map<String, dynamic> json) =>
    PlatformDto(url: json['url'] as String);

Map<String, dynamic> _$PlatformDtoToJson(PlatformDto instance) =>
    <String, dynamic>{'url': instance.url};
