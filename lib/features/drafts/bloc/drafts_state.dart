part of 'drafts_cubit.dart';

class DraftsState {
  static const Object _notSpecified = Object();

  List<DraftEntity> drafts;
  int? pendingDraftId;
  DraftEntity? currentDraft;

  DraftsState({
    required this.drafts,
    this.pendingDraftId,
    this.currentDraft,
  });

  DraftsState copyWith({
    List<DraftEntity>? drafts,
    Object? pendingDraftId,
    Object? currentDraft,
  }) {
    return DraftsState(
      drafts: drafts ?? this.drafts,
      pendingDraftId: identical(pendingDraftId, _notSpecified) ? this.pendingDraftId : pendingDraftId as int?,
      currentDraft: identical(currentDraft, _notSpecified) ? this.currentDraft : currentDraft as DraftEntity?,
    );
  }
}
