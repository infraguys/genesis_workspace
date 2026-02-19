part of 'channel_chat_cubit.dart';

class ChannelChatState {
  static const Object _notSpecified = Object();

  List<MessageEntity> messages;
  bool isMessagePending;
  bool isLoadingMore;
  bool isFoundOldestMessage;
  bool isFoundNewestMessage;
  int? lastMessageId;
  int? firstMessageId;
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
    required this.isFoundOldestMessage,
    required this.isFoundNewestMessage,
    required this.isLoadingMore,
    required this.isMessagePending,
    this.lastMessageId,
    this.firstMessageId,
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
    bool? isFoundOldestMessage,
    bool? isFoundNewestMessage,
    bool? isLoadingMore,
    bool? isMessagePending,
    Object? lastMessageId,
    Object? firstMessageId,
    Object? channel = _notSpecified,
    int? typingUserId,
    TypingEventOp? selfTypingOp,
    Object? topic = _notSpecified,
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
      isFoundOldestMessage: isFoundOldestMessage ?? this.isFoundOldestMessage,
      isFoundNewestMessage: isFoundNewestMessage ?? this.isFoundNewestMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMessagePending: isMessagePending ?? this.isMessagePending,
      lastMessageId: identical(lastMessageId, _notSpecified) ? this.lastMessageId : lastMessageId as int?,
      firstMessageId: identical(firstMessageId, _notSpecified) ? this.firstMessageId : firstMessageId as int?,
      channel: identical(channel, _notSpecified) ? this.channel : channel as StreamEntity?,
      typingUserId: typingUserId ?? this.typingUserId,
      selfTypingOp: selfTypingOp ?? this.selfTypingOp,
      topic: identical(topic, _notSpecified) ? this.topic : topic as TopicEntity?,
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
