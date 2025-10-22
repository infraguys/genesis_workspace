part of 'update_cubit.dart';

class UpdateState {
  const UpdateState({
    this.status = UpdateStatus.initial,
    this.isUpdateRequired = false,
    this.isNewUpdateAvailable = false,
    this.currentVersion = '',
    this.actualVersion = '',
    this.linuxUpdateUrl = '',
    this.errorMessage,
    this.appArchiveUrl = '',
  });

  final UpdateStatus status;
  final bool isUpdateRequired;
  final bool isNewUpdateAvailable;
  final String currentVersion;
  final String actualVersion;
  final String linuxUpdateUrl;
  final String? errorMessage;
  final String appArchiveUrl;

  UpdateState copyWith({
    UpdateStatus? status,
    bool? isUpdateRequired,
    bool? isNewUpdateAvailable,
    String? currentVersion,
    String? actualVersion,
    String? linuxUpdateUrl,
    String? errorMessage,
    String? appArchiveUrl,
  }) {
    return UpdateState(
      status: status ?? this.status,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      isNewUpdateAvailable: isNewUpdateAvailable ?? this.isNewUpdateAvailable,
      currentVersion: currentVersion ?? this.currentVersion,
      actualVersion: actualVersion ?? this.actualVersion,
      linuxUpdateUrl: linuxUpdateUrl ?? this.linuxUpdateUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      appArchiveUrl: appArchiveUrl ?? this.appArchiveUrl,
    );
  }
}

enum UpdateStatus { initial, loading, success, failure }
