part of 'channel_chat_cubit.dart';

class ChannelChatState {
  static const Object _notSpecified = Object();

  List<MessageEntity> messages;
  bool isMessagePending;
  bool isLoadingMore;
  bool isAllMessagesLoaded;
  int? lastMessageId;
  StreamEntity? channel;
  TopicEntity? topic;
  int? typingUserId;
  TypingEventOp selfTypingOp;
  Set<int> pendingToMarkAsRead;
  bool isMessagesPending;
  List<UploadFileEntity> uploadedFiles;
  String uploadedFilesString;
  String? uploadFileError;
  String? uploadFileErrorName;
  List<EditingAttachment> editingAttachments;
  bool isEdited;
  bool showMentionPopup;
  List<UserEntity> suggestedMentions;
  bool isSuggestionsPending;
  List<UserEntity> filteredSuggestedMentions;
  Set<int> channelMembers;
  int? myUserId;

  ChannelChatState({
    required this.messages,
    required this.isAllMessagesLoaded,
    required this.isLoadingMore,
    required this.isMessagePending,
    this.lastMessageId,
    this.channel,
    this.typingUserId,
    required this.selfTypingOp,
    this.topic,
    required this.pendingToMarkAsRead,
    required this.isMessagesPending,
    required this.uploadedFiles,
    required this.uploadedFilesString,
    this.uploadFileError,
    this.uploadFileErrorName,
    required this.editingAttachments,
    required this.isEdited,
    required this.showMentionPopup,
    required this.suggestedMentions,
    required this.isSuggestionsPending,
    required this.filteredSuggestedMentions,
    required this.channelMembers,
    this.myUserId,
  });

  ChannelChatState copyWith({
    List<MessageEntity>? messages,
    bool? isAllMessagesLoaded,
    bool? isLoadingMore,
    bool? isMessagePending,
    int? lastMessageId,
    StreamEntity? channel,
    int? typingUserId,
    TypingEventOp? selfTypingOp,
    TopicEntity? topic,
    Set<int>? pendingToMarkAsRead,
    bool? isMessagesPending,
    List<UploadFileEntity>? uploadedFiles,
    String? uploadedFilesString,
    Object? uploadFileError = _notSpecified,
    Object? uploadFileErrorName = _notSpecified,
    List<EditingAttachment>? editingAttachments,
    bool? isEdited,
    bool? showMentionPopup,
    List<UserEntity>? suggestedMentions,
    bool? isSuggestionsPending,
    List<UserEntity>? filteredSuggestedMentions,
    Set<int>? channelMembers,
    int? myUserId,
  }) {
    return ChannelChatState(
      messages: messages ?? this.messages,
      isAllMessagesLoaded: isAllMessagesLoaded ?? this.isAllMessagesLoaded,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMessagePending: isMessagePending ?? this.isMessagePending,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      channel: channel ?? this.channel,
      typingUserId: typingUserId ?? this.typingUserId,
      selfTypingOp: selfTypingOp ?? this.selfTypingOp,
      topic: topic ?? this.topic,
      pendingToMarkAsRead: pendingToMarkAsRead ?? this.pendingToMarkAsRead,
      isMessagesPending: isMessagesPending ?? this.isMessagesPending,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      uploadedFilesString: uploadedFilesString ?? this.uploadedFilesString,
      uploadFileError: identical(uploadFileError, _notSpecified) ? this.uploadFileError : uploadFileError as String?,
      uploadFileErrorName: identical(uploadFileErrorName, _notSpecified)
          ? this.uploadFileErrorName
          : uploadFileErrorName as String?,
      editingAttachments: editingAttachments ?? this.editingAttachments,
      isEdited: isEdited ?? this.isEdited,
      showMentionPopup: showMentionPopup ?? this.showMentionPopup,
      suggestedMentions: suggestedMentions ?? this.suggestedMentions,
      isSuggestionsPending: isSuggestionsPending ?? this.isSuggestionsPending,
      filteredSuggestedMentions: filteredSuggestedMentions ?? this.filteredSuggestedMentions,
      channelMembers: channelMembers ?? this.channelMembers,
      myUserId: myUserId ?? this.myUserId,
    );
  }
}
