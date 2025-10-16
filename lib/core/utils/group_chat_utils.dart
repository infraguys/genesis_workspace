import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class GroupChatUtils {
  static const int _offset = 1 << 30; // prevent collisions with user/channel ids
  static const int _prime = 1000003;

  static List<int> sortedUserIds(Iterable<int> userIds) {
    final sorted = List<int>.from(userIds);
    sorted.sort();
    return sorted;
  }

  static List<int> sortedUserIdsFromRecipients(Iterable<RecipientEntity> recipients) {
    return sortedUserIds(recipients.map((recipient) => recipient.userId));
  }

  static int computeGroupIdFromUserIds(Iterable<int> userIds) {
    final sorted = sortedUserIds(userIds);
    int hash = 17;
    for (final id in sorted) {
      hash = (hash * _prime + id) & 0x7fffffff;
    }
    return _offset + hash;
  }

  static int computeGroupIdFromRecipients(Iterable<RecipientEntity> recipients) {
    return computeGroupIdFromUserIds(recipients.map((recipient) => recipient.userId));
  }

  static String buildMembershipKey(Iterable<int> userIds) {
    final sorted = sortedUserIds(userIds);
    return sorted.join('-');
  }

  static String buildMembershipKeyFromRecipients(Iterable<RecipientEntity> recipients) {
    return buildMembershipKey(recipients.map((recipient) => recipient.userId));
  }
}
