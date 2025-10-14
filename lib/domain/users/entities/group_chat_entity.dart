import 'package:equatable/equatable.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class GroupChatEntity extends Equatable {
  final List<RecipientEntity> members;

  const GroupChatEntity({required this.members});

  @override
  List<Object?> get props => [members];
}
