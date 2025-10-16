import 'package:equatable/equatable.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class GroupChatEntity extends Equatable {
  final int id;
  final List<RecipientEntity> members;
  final int unreadMessagesCount;

  const GroupChatEntity({
    required this.id,
    required this.members,
    required this.unreadMessagesCount,
  });

  GroupChatEntity copyWith({
    int? id,
    List<RecipientEntity>? members,
    int? unreadMessagesCount,
  }) {
    return GroupChatEntity(
      id: id ?? this.id,
      members: members ?? this.members,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
    );
  }

  @override
  List<Object?> get props => [id, members, unreadMessagesCount];
}
