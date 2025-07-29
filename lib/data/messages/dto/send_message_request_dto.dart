import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_message_request_dto.g.dart';

@JsonSerializable()
class SendMessageRequestDto {
  final SendMessageType type;
  @JsonKey(fromJson: _toFromJson, toJson: _toToJson)
  final Object to;
  final String content;
  final String? topic;
  @JsonKey(name: 'stream_id')
  final int? streamId;

  SendMessageRequestDto({
    required this.type,
    required this.to,
    required this.content,
    this.topic,
    this.streamId,
  });

  factory SendMessageRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageRequestDtoToJson(this);

  static Object _toFromJson(dynamic json) {
    if (json is String) return json;
    if (json is int) return json;
    if (json is List<dynamic>) {
      if (json.every((e) => e is int)) return List<int>.from(json);
      if (json.every((e) => e is String)) return List<String>.from(json);
      return json;
    }
    return json;
  }

  static dynamic _toToJson(Object to) {
    return to;
  }

  String? get toAsString => to is String ? to as String : null;
  int? get toAsInt => to is int ? to as int : null;
  List<String>? get toAsStringList => to is List<String> ? to as List<String> : null;
  List<int>? get toAsIntList => to is List<int> ? to as List<int> : null;
}
