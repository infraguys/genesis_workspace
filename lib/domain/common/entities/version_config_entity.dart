class VersionConfigEntity {
  final SpecEntity spec;
  final PolicyEntity policy;
  final LatestEntity latest;
  final VersionsEntity versions;
  final String sha256;

  VersionConfigEntity({
    required this.spec,
    required this.policy,
    required this.latest,
    required this.versions,
    required this.sha256,
  });

  VersionConfigEntity copyWith({String? sha256}) {
    return VersionConfigEntity(
      spec: spec,
      policy: policy,
      latest: latest,
      versions: versions,
      sha256: sha256 ?? this.sha256,
    );
  }
}

class SpecEntity {
  final String schemaVersion;

  SpecEntity({required this.schemaVersion});
}

class PolicyEntity {
  final UpdatePolicyEntity update;

  PolicyEntity({required this.update});
}

class UpdatePolicyEntity {
  final MinVersionEntity minVersion;

  UpdatePolicyEntity({required this.minVersion});
}

class MinVersionEntity {
  final String minStable;
  final String minShortStable;
  final String minDev;
  final String minShortDev;

  MinVersionEntity({
    required this.minStable,
    required this.minShortStable,
    required this.minDev,
    required this.minShortDev,
  });
}

class LatestEntity {
  final ReleaseChannelEntity stable;
  final ReleaseChannelEntity dev;

  LatestEntity({required this.stable, required this.dev});
}

class VersionsEntity {
  final List<VersionEntryEntity> stable;
  final List<VersionEntryEntity> dev;

  VersionsEntity({required this.stable, required this.dev});
}

class ReleaseChannelEntity {
  final String version;
  final String shortVersion;
  final PlatformEntity linux;

  ReleaseChannelEntity({
    required this.version,
    required this.shortVersion,
    required this.linux,
  });
}

class VersionEntryEntity {
  final String version;
  final String shortVersion;
  final PlatformEntity linux;

  VersionEntryEntity({
    required this.version,
    required this.shortVersion,
    required this.linux,
  });
}

class PlatformEntity {
  final String url;

  PlatformEntity({required this.url});
}
