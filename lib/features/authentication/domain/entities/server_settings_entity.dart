class ServerSettingsEntity {
  final String realmName;
  final String realmUri;
  final String realmIcon;
  final List<ExternalAuthenticationMethodEntity> externalAuthenticationMethods;

  ServerSettingsEntity({
    required this.realmName,
    required this.realmUri,
    required this.realmIcon,
    required this.externalAuthenticationMethods,
  });
}

class ExternalAuthenticationMethodEntity {
  final String name;
  final String loginUrl;
  final String signupUrl;
  final String displayName;

  ExternalAuthenticationMethodEntity({
    required this.name,
    required this.loginUrl,
    required this.signupUrl,
    required this.displayName,
  });
}
