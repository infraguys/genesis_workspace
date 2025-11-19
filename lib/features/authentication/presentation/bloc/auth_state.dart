part of 'auth_cubit.dart';

class AuthState {
  final bool isPending;
  final bool isAuthorized;
  final String? errorMessage;
  ServerSettingsEntity? serverSettings;
  final String? otp;
  final Uint8List? rawKey;
  final bool isParseTokenPending;
  final String? parseTokenError;
  final bool hasBaseUrl;
  final bool pasteBaseUrlPending;
  final bool serverSettingsPending;
  final OrganizationEntity? selectedOrganization;

  AuthState({
    required this.isPending,
    required this.isAuthorized,
    this.errorMessage,
    this.serverSettings,
    this.otp,
    this.rawKey,
    required this.isParseTokenPending,
    this.parseTokenError,
    required this.hasBaseUrl,
    required this.pasteBaseUrlPending,
    required this.serverSettingsPending,
    this.selectedOrganization,
  });

  AuthState copyWith({
    bool? isPending,
    bool? isAuthorized,
    String? errorMessage,
    ServerSettingsEntity? serverSettings,
    String? otp,
    Uint8List? rawKey,
    bool? isParseTokenPending,
    String? parseTokenError,
    bool? hasBaseUrl,
    bool? pasteBaseUrlPending,
    bool? serverSettingsPending,
    OrganizationEntity? selectedOrganization,
  }) {
    return AuthState(
      isPending: isPending ?? this.isPending,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      errorMessage: errorMessage ?? this.errorMessage,
      serverSettings: serverSettings ?? this.serverSettings,
      otp: otp ?? this.otp,
      rawKey: rawKey ?? this.rawKey,
      isParseTokenPending: isParseTokenPending ?? this.isParseTokenPending,
      parseTokenError: parseTokenError ?? this.parseTokenError,
      hasBaseUrl: hasBaseUrl ?? this.hasBaseUrl,
      pasteBaseUrlPending: pasteBaseUrlPending ?? this.pasteBaseUrlPending,
      serverSettingsPending: serverSettingsPending ?? this.serverSettingsPending,
      selectedOrganization: selectedOrganization ?? this.selectedOrganization,
    );
  }
}
