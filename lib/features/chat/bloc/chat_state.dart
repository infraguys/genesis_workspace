part of 'chat_cubit.dart';

class ChatState {
  List<MessageEntity> messages;
  int? chatId;
  int? typingId;
  int? myUserId;
  int? lastMessageId;
  bool isMessagePending;
  bool isLoadingMore;
  bool isAllMessagesLoaded;
  TypingEventOp selfTypingOp;
  Set<int> pendingToMarkAsRead;
  DmUserEntity? userEntity;
  List<UploadFileEntity> uploadedFiles;
  String uploadedFilesString;
  String? uploadFileError;
  String? uploadFileErrorName;
  bool isEdit;
  MessageEntity? editingMessage;
  List<EditingAttachment> editingAttachments;
  bool isEdited;
  bool showMentionPopup;
  List<UserEntity> suggestedMentions;
  List<UserEntity> filteredSuggestedMentions;
  bool isSuggestionsPending;

  ChatState({
    required this.messages,
    this.chatId,
    this.typingId,
    this.myUserId,
    this.lastMessageId,
    required this.isMessagePending,
    required this.isLoadingMore,
    required this.isAllMessagesLoaded,
    required this.selfTypingOp,
    required this.pendingToMarkAsRead,
    this.userEntity,
    required this.uploadedFiles,
    required this.uploadedFilesString,
    this.uploadFileError,
    this.uploadFileErrorName,
    required this.isEdit,
    this.editingMessage,
    required this.editingAttachments,
    required this.isEdited,
    required this.showMentionPopup,
    required this.suggestedMentions,
    required this.isSuggestionsPending,
    required this.filteredSuggestedMentions,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    int? chatId,
    int? typingId,
    int? myUserId,
    int? lastMessageId,
    bool? isMessagePending,
    bool? isLoadingMore,
    bool? isAllMessagesLoaded,
    TypingEventOp? selfTypingOp,
    Set<int>? pendingToMarkAsRead,
    DmUserEntity? userEntity,
    List<UploadFileEntity>? uploadedFiles,
    String? uploadedFilesString,
    String? uploadFileError,
    String? uploadFileErrorName,
    bool? isEdit,
    MessageEntity? editingMessage,
    List<EditingAttachment>? editingAttachments,
    bool? isEdited,
    bool? showMentionPopup,
    List<UserEntity>? suggestedMentions,
    List<UserEntity>? filteredSuggestedMentions,
    bool? isSuggestionsPending,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      typingId: typingId ?? this.typingId,
      myUserId: myUserId ?? this.myUserId,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      isMessagePending: isMessagePending ?? this.isMessagePending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isAllMessagesLoaded: isAllMessagesLoaded ?? this.isAllMessagesLoaded,
      selfTypingOp: selfTypingOp ?? this.selfTypingOp,
      pendingToMarkAsRead: pendingToMarkAsRead ?? this.pendingToMarkAsRead,
      userEntity: userEntity ?? this.userEntity,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      uploadedFilesString: uploadedFilesString ?? this.uploadedFilesString,
      uploadFileError: uploadFileError ?? this.uploadFileError,
      uploadFileErrorName: uploadFileErrorName ?? this.uploadFileErrorName,
      isEdit: isEdit ?? this.isEdit,
      editingMessage: editingMessage ?? this.editingMessage,
      editingAttachments: editingAttachments ?? this.editingAttachments,
      isEdited: isEdited ?? this.isEdited,
      showMentionPopup: showMentionPopup ?? this.showMentionPopup,
      suggestedMentions: suggestedMentions ?? this.suggestedMentions,
      isSuggestionsPending: isSuggestionsPending ?? this.isSuggestionsPending,
      filteredSuggestedMentions: filteredSuggestedMentions ?? this.filteredSuggestedMentions,
    );
  }
}
