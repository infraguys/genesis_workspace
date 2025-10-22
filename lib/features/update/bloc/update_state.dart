part of 'update_cubit.dart';

class UpdateState {
  const UpdateState({
    required this.status,
    required this.isUpdateRequired,
    required this.isNewUpdateAvailable,
    required this.currentVersion,
    required this.actualVersion,
    this.errorMessage,
    this.versionConfigEntity,
  });

  final UpdateStatus status;
  final bool isUpdateRequired;
  final bool isNewUpdateAvailable;
  final String currentVersion;
  final String actualVersion;
  final String? errorMessage;
  final VersionConfigEntity? versionConfigEntity;

  UpdateState copyWith({
    UpdateStatus? status,
    bool? isUpdateRequired,
    bool? isNewUpdateAvailable,
    String? currentVersion,
    String? actualVersion,
    String? errorMessage,
    VersionConfigEntity? versionConfigEntity,
  }) {
    return UpdateState(
      status: status ?? this.status,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      isNewUpdateAvailable: isNewUpdateAvailable ?? this.isNewUpdateAvailable,
      currentVersion: currentVersion ?? this.currentVersion,
      actualVersion: actualVersion ?? this.actualVersion,
      errorMessage: errorMessage ?? this.errorMessage,
      versionConfigEntity: versionConfigEntity ?? this.versionConfigEntity,
    );
  }
}

enum UpdateStatus { initial, loading, success, failure }
