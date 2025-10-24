part of 'messenger_cubit.dart';

class MessengerState {
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  final Map<int, FolderMembers> folderMembersById;

  MessengerState({
    required this.folders,
    required this.selectedFolderIndex,
    required this.folderMembersById,
  });

  MessengerState copyWith({
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
    Map<int, FolderMembers>? folderMembersById,
  }) {
    return MessengerState(
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      folderMembersById: folderMembersById ?? this.folderMembersById,
    );
  }
}
