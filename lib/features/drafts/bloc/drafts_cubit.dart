import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/drafts/entities/create_drafts_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';
import 'package:genesis_workspace/domain/drafts/usecases/create_drafts_use_case.dart';
import 'package:genesis_workspace/domain/drafts/usecases/get_drafts_use_case.dart';
import 'package:injectable/injectable.dart';

part 'drafts_state.dart';

@injectable
class DraftsCubit extends Cubit<DraftsState> {
  DraftsCubit(this._createDraftsUseCase, this._getDraftsUseCase) : super(DraftsState(drafts: []));

  final GetDraftsUseCase _getDraftsUseCase;
  final CreateDraftsUseCase _createDraftsUseCase;

  Future<void> getDrafts() async {
    try {
      final response = await _getDraftsUseCase.call();
      emit(state.copyWith(drafts: response.drafts));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  DraftEntity? getDraftForChat({
    List<int>? userIds,
    int? channelId,
    String? topicName,
  }) {
    if (userIds != null) {
      return state.drafts.firstWhereOrNull(
        (draft) => draft.matchesUsers(userIds),
      );
    }

    if (channelId != null) {
      return state.drafts.firstWhereOrNull(
        (draft) => draft.matchesChannel(
          channelId: channelId,
          topicName: topicName,
        ),
      );
    }

    return null;
  }

  Future<void> saveDraft(CreateDraftsRequestEntity body) async {
    try {
      final response = await _createDraftsUseCase.call(body);
      await getDrafts();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }
}
