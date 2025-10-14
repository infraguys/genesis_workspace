import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class GroupChatEntity {
  List<RecipientEntity> members;

  GroupChatEntity({required this.members});
}
