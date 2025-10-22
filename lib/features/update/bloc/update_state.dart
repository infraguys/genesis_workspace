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
    required this.operationStatus,
    required this.downloadedBytes,
    required this.totalBytes,
    this.selectedVersion,
    this.updateError,
  });

  final UpdateStatus status;
  final bool isUpdateRequired;
  final bool isNewUpdateAvailable;
  final String currentVersion;
  final String actualVersion;
  final String? errorMessage;
  final VersionConfigEntity? versionConfigEntity;
  final UpdateOperationStatus operationStatus;
  final int downloadedBytes;
  final int totalBytes;
  final VersionEntryEntity? selectedVersion;
  final String? updateError;

  UpdateState copyWith({
    UpdateStatus? status,
    bool? isUpdateRequired,
    bool? isNewUpdateAvailable,
    String? currentVersion,
    String? actualVersion,
    Object? errorMessage = _sentinel,
    Object? versionConfigEntity = _sentinel,
    UpdateOperationStatus? operationStatus,
    int? downloadedBytes,
    int? totalBytes,
    Object? selectedVersion = _sentinel,
    Object? updateError = _sentinel,
  }) {
    return UpdateState(
      status: status ?? this.status,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      isNewUpdateAvailable: isNewUpdateAvailable ?? this.isNewUpdateAvailable,
      currentVersion: currentVersion ?? this.currentVersion,
      actualVersion: actualVersion ?? this.actualVersion,
      errorMessage:
          identical(errorMessage, _sentinel) ? this.errorMessage : errorMessage as String?,
      versionConfigEntity: identical(versionConfigEntity, _sentinel)
          ? this.versionConfigEntity
          : versionConfigEntity as VersionConfigEntity?,
      operationStatus: operationStatus ?? this.operationStatus,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      selectedVersion: identical(selectedVersion, _sentinel)
          ? this.selectedVersion
          : selectedVersion as VersionEntryEntity?,
      updateError:
          identical(updateError, _sentinel) ? this.updateError : updateError as String?,
    );
  }

  static const Object _sentinel = Object();
}

enum UpdateStatus { initial, loading, success, failure }

enum UpdateOperationStatus { idle, downloading, installing, readyToRestart, failure }
