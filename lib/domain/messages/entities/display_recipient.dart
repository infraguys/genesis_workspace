import 'package:equatable/equatable.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

sealed class DisplayRecipient extends Equatable {
  const DisplayRecipient();

  dynamic toJson();

  static DisplayRecipient fromJson(dynamic json) {
    if (json is String) {
      return StreamDisplayRecipient(json);
    }
    if (json is List) {
      final recipients = json.map((recipient) => RecipientEntity.fromJson(recipient as Map<String, dynamic>)).toList();
      return DirectMessageRecipients(recipients);
    }
    throw FormatException('Unsupported display_recipient format: ${json.runtimeType}');
  }
}

class StreamDisplayRecipient extends DisplayRecipient {
  final String streamName;
  const StreamDisplayRecipient(this.streamName);

  @override
  dynamic toJson() => streamName;

  @override
  List<Object?> get props => [streamName];
}

class DirectMessageRecipients extends DisplayRecipient {
  final List<RecipientEntity> recipients;
  const DirectMessageRecipients(this.recipients);

  @override
  dynamic toJson() => recipients.map((recipient) => recipient.toJson()).toList();

  @override
  List<Object?> get props => [recipients];
}

extension DisplayRecipientX on DisplayRecipient {
  bool get isStream => this is StreamDisplayRecipient;
  bool get isDirect => this is DirectMessageRecipients;

  String get streamName => switch (this) {
    StreamDisplayRecipient(:final streamName) => streamName,
    _ => throw StateError('DisplayRecipient is not a stream'),
  };

  List<RecipientEntity> get recipients => switch (this) {
    DirectMessageRecipients(:final recipients) => recipients,
    _ => throw StateError('DisplayRecipient is not direct message'),
  };
}
