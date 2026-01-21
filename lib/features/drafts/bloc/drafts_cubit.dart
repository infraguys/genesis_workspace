import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/drafts/entities/create_drafts_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/edit_draft_entity.dart';
import 'package:genesis_workspace/domain/drafts/usecases/create_drafts_use_case.dart';
import 'package:genesis_workspace/domain/drafts/usecases/delete_draft_use_case.dart';
import 'package:genesis_workspace/domain/drafts/usecases/edit_draft_use_case.dart';
import 'package:genesis_workspace/domain/drafts/usecases/get_drafts_use_case.dart';
import 'package:injectable/injectable.dart';

part 'drafts_state.dart';

@injectable
class DraftsCubit extends Cubit<DraftsState> {
  DraftsCubit(
    this._createDraftsUseCase,
    this._getDraftsUseCase,
    this._deleteDraftUseCase,
    this._editDraftUseCase,
  ) : super(
        DraftsState(
          drafts: [],
          pendingDraftId: null,
          currentDraft: null,
        ),
      );

  final GetDraftsUseCase _getDraftsUseCase;
  final CreateDraftsUseCase _createDraftsUseCase;
  final DeleteDraftUseCase _deleteDraftUseCase;
  final EditDraftUseCase _editDraftUseCase;

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
    final bodyDraft = body.drafts.first;
    DraftEntity? draft;
    if (bodyDraft.type == .private) {
      draft = state.drafts.firstWhereOrNull((draft) => draft.matchesUsers(bodyDraft.to));
    }

    if (bodyDraft.type == .stream) {
      draft = state.drafts.firstWhereOrNull(
        (draft) => draft.matchesChannel(
          channelId: bodyDraft.to.first,
          topicName: bodyDraft.topic,
        ),
      );
    }
    if (draft != null) {
      return;
    }
    try {
      await _createDraftsUseCase.call(body);
      await getDrafts();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> deleteDraft(int id) async {
    emit(state.copyWith(pendingDraftId: id));
    try {
      await _deleteDraftUseCase.call(id);
      List<DraftEntity> updatedDrafts = [...state.drafts];
      updatedDrafts.removeWhere((draft) => draft.id == id);
      emit(state.copyWith(drafts: updatedDrafts));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      emit(state.copyWith(pendingDraftId: null));
    }
  }

  Future<void> editDraft(
    int draftId,
    String content, {
    List<int>? userIds,
    int? channelId,
    String? topicName,
  }) async {
    final draft = state.drafts.firstWhere((draft) => draft.id == draftId);
    if (draft.content == content) {
      return;
    }
    if (content.isEmpty) {
      await deleteDraft(draftId);
      return;
    }
    try {
      final body = EditDraftRequestEntity(
        id: draftId,
        draft: draft.copyWith(content: content),
      );
      await _editDraftUseCase.call(body);
      await getDrafts();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }
}
