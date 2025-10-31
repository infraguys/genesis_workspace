part of 'messenger_cubit.dart';

class MessengerState {
  final UserEntity? selfUser;
  final List<FolderItemEntity> folders;
  final int selectedFolderIndex;
  final Map<int, FolderMembers> folderMembersById;
  final List<MessageEntity> messages;
  final List<ChatEntity> chats;

  MessengerState({
    this.selfUser,
    required this.folders,
    required this.selectedFolderIndex,
    required this.folderMembersById,
    required this.messages,
    required this.chats,
  });

  MessengerState copyWith({
    UserEntity? selfUser,
    List<FolderItemEntity>? folders,
    int? selectedFolderIndex,
    Map<int, FolderMembers>? folderMembersById,
    List<MessageEntity>? messages,
    List<ChatEntity>? chats,
  }) {
    return MessengerState(
      selfUser: selfUser ?? this.selfUser,
      folders: folders ?? this.folders,
      selectedFolderIndex: selectedFolderIndex ?? this.selectedFolderIndex,
      folderMembersById: folderMembersById ?? this.folderMembersById,
      messages: messages ?? this.messages,
      chats: chats ?? this.chats,
    );
  }
}
