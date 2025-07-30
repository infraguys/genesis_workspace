import 'package:equatable/equatable.dart';

class TopicEntity extends Equatable {
  final int maxId;
  final String name;
  Set<int> unreadMessages;

  TopicEntity({required this.maxId, required this.name, required this.unreadMessages});

  @override
  List<Object> get props => [name];
}
