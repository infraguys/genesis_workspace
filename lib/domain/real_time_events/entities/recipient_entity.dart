import 'package:equatable/equatable.dart';

class RecipientEntity extends Equatable {
  final int userId;
  final String email;
  final String fullName;

  const RecipientEntity({required this.userId, required this.email, required this.fullName});

  @override
  List<Object?> get props => [userId];
}
