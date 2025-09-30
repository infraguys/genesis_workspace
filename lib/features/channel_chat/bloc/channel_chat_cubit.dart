import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_cubit_mixin.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_widget_mixin.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/send_message_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_message_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_messages_flags_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/upload_file_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/reaction_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/channel_by_id_entity.dart';
import 'package:genesis_workspace/domain/users/entities/channel_members_entity.dart';
import 'package:genesis_workspace/domain/users/entities/stream_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_channel_by_id_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_channel_members_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/set_typing_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'channel_chat_state.dart';

@injectable
class ChannelChatCubit extends Cubit<ChannelChatState>
    with ChatCubitMixin<ChannelChatState>
    implements ChatCubitCapable {
  ChannelChatCubit(
    this._realTimeService,
    this._getMessagesUseCase,
    this._setTypingUseCase,
    this._updateMessagesFlagsUseCase,
    this._sendMessageUseCase,
    this._getChannelByIdUseCase,
    this._getTopicsUseCase,
    this._uploadFileUseCase,
    this._updateMessageUseCase,
    this._getUsersUseCase,
    this._getChannelMembersUseCase,
  ) : super(
        ChannelChatState(
          messages: [],
          isLoadingMore: false,
          isMessagePending: false,
          isAllMessagesLoaded: false,
          lastMessageId: null,
          channel: null,
          typingUserId: null,
          selfTypingOp: TypingEventOp.stop,
          topic: null,
          pendingToMarkAsRead: {},
          isMessagesPending: false,
          uploadedFiles: [],
          uploadedFilesString: '',
          uploadFileErrorName: null,
          uploadFileError: null,
          editingAttachments: [],
          isEdited: false,
          showMentionPopup: false,
          suggestedMentions: [],
          isSuggestionsPending: false,
          filteredSuggestedMentions: [],
          channelMembers: {},
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      onMessageFlagsEvents,
    );
    _reactionsSubscription = _realTimeService.reactionsEventsStream.listen(onReactionEvents);
    _deleteMessageEventsSubscription = _realTimeService.deleteMessageEventsStream.listen(
      onDeleteMessageEvents,
    );

    _updateMessageSubscription = _realTimeService.updateMessageEventsStream.listen(
      onUpdateMessageEvents,
    );
  }

  final RealTimeService _realTimeService;

  final GetMessagesUseCase _getMessagesUseCase;
  final SetTypingUseCase _setTypingUseCase;
  final UpdateMessagesFlagsUseCase _updateMessagesFlagsUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final GetChannelByIdUseCase _getChannelByIdUseCase;
  final GetTopicsUseCase _getTopicsUseCase;
  final UploadFileUseCase _uploadFileUseCase;
  final UpdateMessageUseCase _updateMessageUseCase;
  final GetUsersUseCase _getUsersUseCase;
  final GetChannelMembersUseCase _getChannelMembersUseCase;

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsSubscription;
  late final StreamSubscription<ReactionEventEntity> _reactionsSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageEventsSubscription;
  late final StreamSubscription<UpdateMessageEventEntity> _updateMessageSubscription;

  Timer? _readMessageDebounceTimer;

  @override
  UploadFileUseCase get uploadFileUseCase => _uploadFileUseCase;

  @override
  UpdateMessagesFlagsUseCase get updateMessagesFlagsUseCase => _updateMessagesFlagsUseCase;

  @override
  UpdateMessageUseCase get updateMessageUseCase => _updateMessageUseCase;

  @override
  GetUsersUseCase get getUsersUseCase => _getUsersUseCase;

  @override
  List<UploadFileEntity> getUploadedFiles(ChannelChatState s) => s.uploadedFiles;

  @override
  String getUploadedFilesString(ChannelChatState s) => s.uploadedFilesString;

  @override
  String? getUploadFileError(ChannelChatState s) => s.uploadFileError;

  @override
  String? getUploadFileErrorName(ChannelChatState s) => s.uploadFileErrorName;

  @override
  List<MessageEntity> getStateMessages(ChannelChatState s) => s.messages;

  @override
  Set<int> getPendingToMarkAsRead(ChannelChatState s) => s.pendingToMarkAsRead;

  @override
  List<EditingAttachment> getEditingAttachments(ChannelChatState s) => s.editingAttachments;

  @override
  getShowMentionPopup(ChannelChatState s) => s.showMentionPopup;

  @override
  getSuggestedMentions(ChannelChatState s) => s.suggestedMentions;

  @override
  getIsSuggestionsPending(ChannelChatState s) => s.isSuggestionsPending;

  @override
  getFilteredSuggestedMentions(ChannelChatState s) => s.filteredSuggestedMentions;

  @override
  getChannelMembers(ChannelChatState s) => s.channelMembers;

  @override
  ChannelChatState copyWithCommon({
    List<UploadFileEntity>? uploadedFiles,
    String? uploadedFilesString,
    String? uploadFileError,
    String? uploadFileErrorName,
    List<MessageEntity>? messages,
    List<EditingAttachment>? editingAttachments,
    bool? isEdited,
    bool? showMentionPopup,
    List<UserEntity>? suggestedMentions,
    bool? isSuggestionsPending,
    List<UserEntity>? filteredSuggestedMentions,
  }) {
    return state.copyWith(
      uploadedFiles: uploadedFiles ?? state.uploadedFiles,
      uploadedFilesString: uploadedFilesString ?? state.uploadedFilesString,
      uploadFileError: uploadFileError,
      uploadFileErrorName: uploadFileErrorName,
      messages: messages ?? state.messages,
      editingAttachments: editingAttachments ?? state.editingAttachments,
      isEdited: isEdited ?? state.isEdited,
      showMentionPopup: showMentionPopup ?? state.showMentionPopup,
      suggestedMentions: suggestedMentions ?? state.suggestedMentions,
      isSuggestionsPending: isSuggestionsPending ?? state.isSuggestionsPending,
      filteredSuggestedMentions: filteredSuggestedMentions ?? state.filteredSuggestedMentions,
    );
  }

  Future<void> getInitialData({
    required int streamId,
    String? topicName,
    bool? didUpdateWidget,
    int? unreadMessagesCount,
  }) async {
    emit(state.copyWith(channel: null, topic: null, messages: [], channelMembers: {}));
    try {
      await Future.wait([
        getChannel(streamId: streamId),
        getChannelTopics(streamId: streamId, topicName: topicName),
      ]);
      await getChannelMessages(
        didUpdateWidget: didUpdateWidget,
        unreadMessagesCount: unreadMessagesCount,
      );
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getChannel({required int streamId, String? topicName}) async {
    try {
      final response = await _getChannelByIdUseCase.call(
        ChannelByIdRequestEntity(streamId: streamId),
      );
      final channel = response.stream;
      final channelMembersResponse = await _getChannelMembersUseCase.call(
        ChannelMembersRequestEntity(streamId: channel.streamId),
      );
      emit(
        state.copyWith(
          channel: channel,
          channelMembers: channelMembersResponse.subscribers.toSet(),
        ),
      );
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getChannelTopics({required int streamId, String? topicName}) async {
    try {
      final response = await _getTopicsUseCase.call(streamId);
      final topic = response.where((topic) => topicName == topic.name).firstOrNull;
      emit(state.copyWith(topic: topic));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getChannelMessages({bool? didUpdateWidget, int? unreadMessagesCount}) async {
    emit(state.copyWith(isMessagesPending: true));
    if (didUpdateWidget == true) {
      state.isMessagesPending = true;
      emit(state.copyWith(isMessagesPending: state.isMessagesPending));
    }
    try {
      int numBefore = 25;
      if (unreadMessagesCount != null && unreadMessagesCount > 25) {
        numBefore = unreadMessagesCount + 10;
      }
      final response = await _getMessagesUseCase.call(
        MessagesRequestEntity(
          anchor: MessageAnchor.newest(),
          narrow: [
            MessageNarrowEntity(operator: NarrowOperator.channel, operand: state.channel!.name),
            if (state.topic != null)
              MessageNarrowEntity(operator: NarrowOperator.topic, operand: state.topic!.name),
          ],
          numBefore: numBefore,
          numAfter: 0,
        ),
      );
      final Set<int> channelMembers = {...state.channelMembers};
      final sortedChannelMembers = _sortChannelMembersByRecentMessages(
        channelMembers: channelMembers,
        recentSenderIds: response.messages.reversed.map((message) => message.senderId).toList(),
      );
      emit(
        state.copyWith(
          messages: response.messages,
          isAllMessagesLoaded: response.foundOldest,
          lastMessageId: response.messages.first.id,
          channelMembers: sortedChannelMembers,
        ),
      );
    } catch (e) {
      inspect(e);
    } finally {
      emit(state.copyWith(isMessagesPending: false));
    }
  }

  Future<void> loadMoreMessages() async {
    if (!state.isAllMessagesLoaded) {
      state.isLoadingMore = true;
      emit(state.copyWith(isLoadingMore: state.isLoadingMore));
      try {
        final body = MessagesRequestEntity(
          anchor: MessageAnchor.id(state.lastMessageId ?? 0),
          narrow: [
            MessageNarrowEntity(operator: NarrowOperator.channel, operand: state.channel!.name),
            if (state.topic != null)
              MessageNarrowEntity(operator: NarrowOperator.topic, operand: state.topic!.name),
          ],
          numBefore: 25,
          numAfter: 0,
        );
        final response = await _getMessagesUseCase.call(body);
        state.lastMessageId = response.messages.first.id;
        state.isAllMessagesLoaded = response.foundOldest;
        List<MessageEntity> messages = [...state.messages];
        messages = [...response.messages, ...messages];
        state.isLoadingMore = false;
        emit(
          state.copyWith(
            messages: messages,
            isLoadingMore: state.isLoadingMore,
            isAllMessagesLoaded: state.isAllMessagesLoaded,
          ),
        );
      } catch (e) {
        inspect(e);
      }
    }
  }

  Future<void> sendMessage({required int streamId, required String content, String? topic}) async {
    emit(state.copyWith(isMessagePending: true));
    final String composed = buildMessageContent(content: content);

    final body = SendMessageRequestEntity(
      type: SendMessageType.stream,
      to: [streamId],
      content: composed,
      topic: topic ?? '',
      streamId: streamId,
    );

    try {
      await _sendMessageUseCase.call(body);
      emit(state.copyWith(uploadedFilesString: '', uploadedFiles: []));
    } catch (e) {
      inspect(e);
    } finally {
      emit(state.copyWith(isMessagePending: false));
    }
  }

  Set<int> _sortChannelMembersByRecentMessages({
    required Set<int> channelMembers,
    required List<int> recentSenderIds,
  }) {
    final List<int> sortedMembers = [];

    final Set<int> seen = {};
    for (final senderId in recentSenderIds) {
      if (channelMembers.contains(senderId) && !seen.contains(senderId)) {
        sortedMembers.add(senderId);
        seen.add(senderId);
      }
    }

    for (final memberId in channelMembers) {
      if (!seen.contains(memberId)) {
        sortedMembers.add(memberId);
      }
    }

    return sortedMembers.toSet();
  }

  @override
  Future<void> changeTyping({required TypingEventOp op}) async {
    if (state.selfTypingOp != op) {
      state.selfTypingOp = op;
      try {
        await _setTypingUseCase.call(
          TypingRequestEntity(
            type: SendMessageType.stream,
            op: op,
            streamId: state.channel!.streamId,
            topic: state.topic!.name,
          ),
        );
      } catch (e) {
        inspect(e);
      }
    }
  }

  @override
  void setIsMessagePending(bool value) {
    emit(state.copyWith(isMessagePending: value));
  }

  void _onTypingEvents(TypingEventEntity event) {
    final senderId = event.sender.userId;
    // final isWriting = event.op == TypingEventOp.start && senderId == state.chatId;

    if (false) {
      state.typingUserId = senderId;
    } else {
      state.typingUserId = null;
    }
    emit(state.copyWith(typingUserId: state.typingUserId));
  }

  void _onMessageEvents(MessageEventEntity event) {
    bool isThisChatMessage = event.message.displayRecipient == state.channel!.name;
    String messageSubject = event.message.subject;
    if (isThisChatMessage) {
      if (state.topic == null) {
        state.messages = [...state.messages, event.message];
        emit(state.copyWith(messages: state.messages));
      } else if (state.topic!.name == messageSubject) {
        state.messages = [...state.messages, event.message];
        emit(state.copyWith(messages: state.messages));
      }
    }
  }

  @override
  Future<void> close() {
    _typingEventsSubscription.cancel();
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    _readMessageDebounceTimer?.cancel();
    _reactionsSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    _updateMessageSubscription.cancel();
    return super.close();
  }
}
