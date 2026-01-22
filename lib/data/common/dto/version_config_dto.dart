import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'version_config_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class VersionConfigDto {
  final SpecDto spec;
  final PolicyDto policy;
  final LatestDto latest;
  final VersionsDto versions;

  VersionConfigDto({
    required this.spec,
    required this.policy,
    required this.latest,
    required this.versions,
  });

  factory VersionConfigDto.fromJson(Map<String, dynamic> json) => _$VersionConfigDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VersionConfigDtoToJson(this);

  VersionConfigEntity toEntity() => VersionConfigEntity(
    spec: spec.toEntity(),
    policy: policy.toEntity(),
    latest: latest.toEntity(),
    versions: versions.toEntity(),
    sha256: '',
  );
}

@JsonSerializable()
class SpecDto {
  @JsonKey(name: 'schema_version')
  final String schemaVersion;

  SpecDto({required this.schemaVersion});

  factory SpecDto.fromJson(Map<String, dynamic> json) => _$SpecDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SpecDtoToJson(this);

  SpecEntity toEntity() => SpecEntity(schemaVersion: schemaVersion);
}

@JsonSerializable(explicitToJson: true)
class PolicyDto {
  final UpdatePolicyDto update;

  PolicyDto({required this.update});

  factory PolicyDto.fromJson(Map<String, dynamic> json) => _$PolicyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PolicyDtoToJson(this);

  PolicyEntity toEntity() => PolicyEntity(update: update.toEntity());
}

@JsonSerializable(explicitToJson: true)
class UpdatePolicyDto {
  @JsonKey(name: 'min_version')
  final MinVersionDto minVersion;

  UpdatePolicyDto({required this.minVersion});

  factory UpdatePolicyDto.fromJson(Map<String, dynamic> json) => _$UpdatePolicyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePolicyDtoToJson(this);

  UpdatePolicyEntity toEntity() => UpdatePolicyEntity(minVersion: minVersion.toEntity());
}

@JsonSerializable()
class MinVersionDto {
  @JsonKey(name: 'min_stable')
  final String minStable;

  @JsonKey(name: 'min_short_stable')
  final String minShortStable;

  @JsonKey(name: 'min_dev')
  final String minDev;

  @JsonKey(name: 'min_short_dev')
  final String minShortDev;

  MinVersionDto({
    required this.minStable,
    required this.minShortStable,
    required this.minDev,
    required this.minShortDev,
  });

  factory MinVersionDto.fromJson(Map<String, dynamic> json) => _$MinVersionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MinVersionDtoToJson(this);

  MinVersionEntity toEntity() => MinVersionEntity(
    minStable: minStable,
    minShortStable: minShortStable,
    minDev: minDev,
    minShortDev: minShortDev,
  );
}

@JsonSerializable(explicitToJson: true)
class LatestDto {
  final ReleaseChannelDto stable;
  final ReleaseChannelDto dev;

  LatestDto({required this.stable, required this.dev});

  factory LatestDto.fromJson(Map<String, dynamic> json) => _$LatestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LatestDtoToJson(this);

  LatestEntity toEntity() => LatestEntity(stable: stable.toEntity(), dev: dev.toEntity());
}

@JsonSerializable(explicitToJson: true)
class VersionsDto {
  final List<VersionEntryDto> stable;
  final List<VersionEntryDto> dev;

  VersionsDto({required this.stable, required this.dev});

  factory VersionsDto.fromJson(Map<String, dynamic> json) => _$VersionsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VersionsDtoToJson(this);

  VersionsEntity toEntity() => VersionsEntity(
    stable: stable.map((e) => e.toEntity()).toList(),
    dev: dev.map((e) => e.toEntity()).toList(),
  );
}

@JsonSerializable(explicitToJson: true)
class ReleaseChannelDto {
  final String version;

  @JsonKey(name: 'short_version')
  final String shortVersion;

  final PlatformDto linux;

  ReleaseChannelDto({required this.version, required this.shortVersion, required this.linux});

  factory ReleaseChannelDto.fromJson(Map<String, dynamic> json) => _$ReleaseChannelDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ReleaseChannelDtoToJson(this);

  ReleaseChannelEntity toEntity() =>
      ReleaseChannelEntity(version: version, shortVersion: shortVersion, linux: linux.toEntity());
}

@JsonSerializable(explicitToJson: true)
class VersionEntryDto {
  final String version;

  @JsonKey(name: 'short_version')
  final String shortVersion;

  final PlatformDto linux;
  final PlatformDto? win;

  VersionEntryDto({
    required this.version,
    required this.shortVersion,
    required this.linux,
    required this.win,
  });

  factory VersionEntryDto.fromJson(Map<String, dynamic> json) => _$VersionEntryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VersionEntryDtoToJson(this);

  VersionEntryEntity toEntity() => VersionEntryEntity(
    version: version,
    shortVersion: shortVersion,
    linux: linux.toEntity(),
    win: win?.toEntity(),
  );
}

@JsonSerializable(explicitToJson: true)
class PlatformDto {
  final String url;

  PlatformDto({required this.url});

  factory PlatformDto.fromJson(Map<String, dynamic> json) => _$PlatformDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformDtoToJson(this);

  PlatformEntity toEntity() => PlatformEntity(url: url);
}
