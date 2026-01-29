import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/domain/channels/entities/update_topic_muting_entity.dart';
import 'package:genesis_workspace/domain/channels/usecases/update_topic_muting_use_case.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_subscription_settings_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/update_subscription_settings_use_case.dart';
import 'package:injectable/injectable.dart';

part 'mute_state.dart';

@injectable
class MuteCubit extends Cubit<MuteState> {
  MuteCubit(this._updateSubscriptionSettingsUseCase, this._updateTopicMutingUseCase) : super(MuteInitial());

  final UpdateSubscriptionSettingsUseCase _updateSubscriptionSettingsUseCase;
  final UpdateTopicMutingUseCase _updateTopicMutingUseCase;

  Future<void> muteChannel(ChatEntity chat) async {
    if (chat.type != ChatType.channel || chat.streamId == null) {
      return;
    }
    try {
      final UpdateSubscriptionRequestEntity body = UpdateSubscriptionRequestEntity(
        updates: [SubscriptionUpdateEntity(streamId: chat.streamId!, isMuted: true)],
      );
      await _updateSubscriptionSettingsUseCase.call(body);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
      rethrow;
    }
  }

  Future<void> unmuteChannel(ChatEntity chat) async {
    if (chat.type != ChatType.channel || chat.streamId == null) {
      return;
    }
    try {
      final UpdateSubscriptionRequestEntity body = UpdateSubscriptionRequestEntity(
        updates: [SubscriptionUpdateEntity(streamId: chat.streamId!, isMuted: false)],
      );
      await _updateSubscriptionSettingsUseCase.call(body);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
      rethrow;
    }
  }

  Future<void> muteTopic({required int streamId, required String topic}) async {
    try {
      final body = UpdateTopicMutingRequestEntity(
        streamId: streamId,
        topic: topic,
        policy: .muted,
      );
      await _updateTopicMutingUseCase.call(body);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
      rethrow;
    }
  }

  Future<void> unmuteTopic({required int streamId, required String topic}) async {
    try {
      final body = UpdateTopicMutingRequestEntity(
        streamId: streamId,
        topic: topic,
        policy: .unmuted,
      );
      await _updateTopicMutingUseCase.call(body);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
      rethrow;
    }
  }
}
