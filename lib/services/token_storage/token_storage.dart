abstract class TokenStorage {
  Future<void> saveToken({
    required String baseUrl,
    required String token,
    required String email,
  });
  Future<void> saveSessionIdCookie({
    required String baseUrl,
    required String sessionId,
  });
  Future<void> saveCsrfTokenCookie({
    required String baseUrl,
    required String csrftoken,
  });
  Future<String?> getToken(String baseUrl);
  Future<String?> getSessionId(String baseUrl);
  Future<String?> getCsrftoken(String baseUrl);
  Future<void> deleteToken(String baseUrl);
  Future<void> deleteSessionId(String baseUrl);
  Future<void> deleteCsrfToken(String baseUrl);

  Future<void> clearAll();
}
class TokenStorageKeys {
  static const String token = 'auth_token';
  static const String sessionId = 'session_id';
  static const String csrftoken = 'csrftoken';
}
