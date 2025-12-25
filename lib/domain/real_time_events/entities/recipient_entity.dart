import 'package:equatable/equatable.dart';

class RecipientEntity extends Equatable {
  final int userId;
  final String email;
  final String fullName;

  const RecipientEntity({required this.userId, required this.email, required this.fullName});

  Map<String, dynamic> toJson() => {
    'email': email,
    'userId': userId,
    'full_name': fullName,
  };

  factory RecipientEntity.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'] ?? json['user_id'] ?? json['userId'];
    return RecipientEntity(
      userId: (idValue as num?)?.toInt() ?? -1,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [userId];
}
