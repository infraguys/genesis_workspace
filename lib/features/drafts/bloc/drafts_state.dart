part of 'drafts_cubit.dart';

class DraftsState {
  static const Object _notSpecified = Object();

  List<DraftEntity> drafts;
  int? pendingDraftId;

  DraftsState({required this.drafts, this.pendingDraftId});

  DraftsState copyWith({
    List<DraftEntity>? drafts,
    Object? pendingDraftId,
  }) {
    return DraftsState(
      drafts: drafts ?? this.drafts,
      pendingDraftId: identical(pendingDraftId, _notSpecified) ? this.pendingDraftId : pendingDraftId as int?,
    );
  }
}
