class ApiKeyRequestDto {
  final String username;
  final String password;

  ApiKeyRequestDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}
