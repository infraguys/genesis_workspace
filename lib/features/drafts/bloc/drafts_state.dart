part of 'drafts_cubit.dart';

class DraftsState {
  List<DraftEntity> drafts;

  DraftsState({required this.drafts});

  DraftsState copyWith({List<DraftEntity>? drafts}) {
    return DraftsState(drafts: drafts ?? this.drafts);
  }
}
