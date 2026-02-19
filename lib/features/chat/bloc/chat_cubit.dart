import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_cubit_mixin.dart';
import 'package:genesis_workspace/core/mixins/chat/chat_widget_mixin.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
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
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/users_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_presence_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/set_typing_use_case.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';

part 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> with ChatCubitMixin<ChatState> implements ChatCubitCapable {
  ChatCubit(
    this._realTimeService,
    this._getMessagesUseCase,
    this._sendMessageUseCase,
    this._setTypingUseCase,
    this._updateMessagesFlagsUseCase,
    this._getUserByIdUseCase,
    this._getUserPresenceUseCase,
    this._uploadFileUseCase,
    this._updateMessageUseCase,
    this._getUsersUseCase,
  ) : super(
        ChatState(
          messages: [],
          chatIds: null,
          typingId: null,
          myUserId: null,
          isMessagePending: false,
          isLoadingMore: false,
          isFoundNewestMessage: false,
          isFoundOldestMessage: false,
          selfTypingOp: TypingEventOp.stop,
          pendingToMarkAsRead: {},
          userEntity: null,
          uploadedFiles: [],
          uploadedFilesString: '',
          uploadFileErrorName: null,
          uploadFileError: null,
          isEdit: false,
          editingMessage: null,
          editingAttachments: [],
          isEdited: false,
          showMentionPopup: false,
          suggestedMentions: [],
          isSuggestionsPending: false,
          filteredSuggestedMentions: [],
          groupUsers: null,
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messageEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messageFlagsEventsStream.listen(
      onMessageFlagsEvents,
    );
    _reactionsSubscription = _realTimeService.reactionEventsStream.listen(onReactionEvents);
    _deleteMessageSubscription = _realTimeService.deleteMessageEventsStream.listen(
      onDeleteMessageEvents,
    );
    _updateMessageSubscription = _realTimeService.updateMessageEventsStream.listen(
      onUpdateMessageEvents,
    );
  }

  final MultiPollingService _realTimeService;

  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final SetTypingUseCase _setTypingUseCase;
  final UpdateMessagesFlagsUseCase _updateMessagesFlagsUseCase;
  final GetUserByIdUseCase _getUserByIdUseCase;
  final GetUserPresenceUseCase _getUserPresenceUseCase;
  final UploadFileUseCase _uploadFileUseCase;
  final UpdateMessageUseCase _updateMessageUseCase;
  final GetUsersUseCase _getUsersUseCase;

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsSubscription;
  late final StreamSubscription<ReactionEventEntity> _reactionsSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageSubscription;
  late final StreamSubscription<UpdateMessageEventEntity> _updateMessageSubscription;

  Timer? _readMessageDebounceTimer;

  @override
  UploadFileUseCase get uploadFileUseCase => _uploadFileUseCase;

  @override
  UpdateMessageUseCase get updateMessageUseCase => _updateMessageUseCase;

  @override
  UpdateMessagesFlagsUseCase get updateMessagesFlagsUseCase => _updateMessagesFlagsUseCase;

  @override
  GetUsersUseCase get getUsersUseCase => _getUsersUseCase;

  @override
  List<UploadFileEntity> getUploadedFiles(ChatState s) => s.uploadedFiles;

  @override
  String getUploadedFilesString(ChatState s) => s.uploadedFilesString;

  @override
  String? getUploadFileError(ChatState s) => s.uploadFileError;

  @override
  String? getUploadFileErrorName(ChatState s) => s.uploadFileErrorName;

  @override
  List<MessageEntity> getStateMessages(ChatState s) => s.messages;

  @override
  Set<int> getPendingToMarkAsRead(ChatState s) => s.pendingToMarkAsRead;

  @override
  List<EditingAttachment> getEditingAttachments(ChatState s) => s.editingAttachments;

  @override
  bool getShowMentionPopup(ChatState s) => s.showMentionPopup;

  @override
  List<UserEntity> getSuggestedMentions(ChatState s) => s.suggestedMentions;

  @override
  bool getIsSuggestionsPending(ChatState s) => s.isSuggestionsPending;

  @override
  List<UserEntity> getFilteredSuggestedMentions(ChatState s) => s.filteredSuggestedMentions;

  @override
  getChannelMembers(ChatState s) => s.chatIds != null ? s.chatIds! : {};

  @override
  ChatState copyWithCommon({
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

  Future<void> getMessagesNear() async {
    try {
      final operand = state.chatIds!.toList();
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.id(5816),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.dm, operand: operand)],
        numBefore: 10,
        numAfter: 10,
      );
      final response = await _getMessagesUseCase.call(body);
      inspect(response);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> getInitialData({
    required List<int> userIds,
    required int myUserId,
    int? firstMessageId,
    // int? unreadMessagesCount,
  }) async {
    state.chatIds = userIds.toSet();
    if (userIds.length == 2) {
      final userId = userIds.firstWhere((userId) => userId != myUserId);
      try {
        final UserEntity user = await _getUserByIdUseCase.call(userId);
        final DmUserEntity dmUser = user.toDmUser();

        if (!user.isBot) {
          final presence = await _getUserPresenceUseCase.call(userId);
          dmUser.presenceStatus = presence.userPresence.aggregated!.status;
          dmUser.presenceTimestamp = presence.userPresence.aggregated!.timestamp;
        }

        emit(state.copyWith(userEntity: dmUser));
      } catch (e) {
        inspect(e);
      }
    } else if (userIds.length == 1 && myUserId == userIds.first) {
      try {
        final UserEntity user = await _getUserByIdUseCase.call(userIds.first);
        final DmUserEntity dmUser = user.toDmUser();
        emit(state.copyWith(userEntity: dmUser));
      } catch (e) {
        inspect(e);
      }
    } else {
      try {
        final ids = [...userIds, myUserId];
        final body = UsersRequestEntity(userIds: ids);
        final List<UserEntity> users = await _getUsersUseCase.call(body);
        emit(state.copyWith(groupUsers: users.map((user) => user.toDmUser()).toList()));
      } catch (e) {
        inspect(e);
      }
    }
    await getMessages(myUserId: myUserId, firstMessageId: firstMessageId);
  }

  Future<void> getMessages({required int myUserId, int? firstMessageId}) async {
    state.myUserId = myUserId;
    int numBefore = 25;

    try {
      final operand = state.chatIds!.toList();
      final body = MessagesRequestEntity(
        anchor: firstMessageId != null ? MessageAnchor.id(firstMessageId) : MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.dm, operand: operand)],
        numBefore: numBefore,
        numAfter: firstMessageId != null ? 25 : 0,
      );
      final response = await _getMessagesUseCase.call(body);
      if (response.messages.isNotEmpty) {
        state.firstMessageId = response.messages.first.id;
        state.lastMessageId = response.messages.last.id;
      }
      emit(
        state.copyWith(
          messages: response.messages,
          isFoundOldestMessage: response.foundOldest,
          isFoundNewestMessage: response.foundNewest,
        ),
      );
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getUnreadMessages() async {
    final organizationId = AppConstants.selectedOrganizationId;
    final connection = _realTimeService.activeConnections[organizationId];
    if (connection?.isActive ?? false) return;
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [
          MessageNarrowEntity(operator: NarrowOperator.dm, operand: state.chatIds!.toList()),
          MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread'),
        ],
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase(body);
      final updatedMessages = [...state.messages];
      updatedMessages.addAll(response.messages);
      if (updatedMessages.isNotEmpty) {
        state.firstMessageId = updatedMessages.first.id;
        state.lastMessageId = updatedMessages.last.id;
      }
      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> loadMorePrevMessages() async {
    if (state.isFoundOldestMessage) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final operand = state.chatIds!.toList();
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.id(state.firstMessageId ?? 0),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.dm, operand: operand)],
        numBefore: 25,
        numAfter: 0,
        includeAnchor: false,
      );
      final response = await _getMessagesUseCase.call(body);
      if (response.messages.isNotEmpty) {
        state.firstMessageId = response.messages.first.id;
      }
      final messages = [...response.messages, ...state.messages];
      emit(
        state.copyWith(
          messages: messages,
          isFoundOldestMessage: response.foundOldest,
        ),
      );
    } catch (e) {
      inspect(e);
    } finally {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> loadMoreNextMessages() async {
    if (state.isFoundNewestMessage) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final operand = state.chatIds!.toList();
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.id(state.lastMessageId ?? state.firstMessageId ?? 0),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.dm, operand: operand)],
        numBefore: 0,
        numAfter: 25,
        includeAnchor: false,
      );
      final response = await _getMessagesUseCase.call(body);
      if (response.messages.isNotEmpty) {
        state.lastMessageId = response.messages.last.id;
      }
      final messages = [...state.messages, ...response.messages];
      emit(
        state.copyWith(
          messages: messages,
          isFoundNewestMessage: response.foundNewest,
        ),
      );
    } catch (e) {
      inspect(e);
    } finally {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  @override
  Future<void> changeTyping({required TypingEventOp op}) async {
    if (state.selfTypingOp != op) {
      state.selfTypingOp = op;
      try {
        await _setTypingUseCase.call(
          TypingRequestEntity(type: SendMessageType.direct, op: op, to: state.chatIds!.toList()),
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

  Future<void> sendMessage({required String content, List<int>? chatIds}) async {
    emit(state.copyWith(isMessagePending: true));
    final String composed = buildMessageContent(content: content, stripExistingAttachmentsFromContent: false);

    final body = SendMessageRequestEntity(
      type: SendMessageType.direct,
      to: chatIds ?? state.chatIds!.toList(),
      content: composed,
    );

    try {
      await _sendMessageUseCase.call(body);
      emit(state.copyWith(uploadedFilesString: '', uploadedFiles: []));
    } on DioException {
      rethrow;
    } catch (e) {
      inspect(e);
    } finally {
      emit(state.copyWith(isMessagePending: false));
    }
  }

  void clearUploadFileError() {
    emit(
      state.copyWith(uploadFileError: null, uploadFileErrorName: null),
    );
  }

  void _onTypingEvents(TypingEventEntity event) {
    final senderId = event.sender.userId;
    final isWriting = event.op == TypingEventOp.start && (state.chatIds?.any((id) => id == senderId) ?? false);

    if (isWriting) {
      state.typingId = senderId;
    } else {
      state.typingId = null;
    }
    emit(state.copyWith(typingId: state.typingId));
  }

  void _onMessageEvents(MessageEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;
    bool isThisChatMessage = false;
    if (event.message.isGroupChatMessage) {
      final chatIds = state.chatIds?.toList();
      final messageRecipients = event.message.displayRecipient.recipients.map((recipient) => recipient.userId).toList();
      isThisChatMessage = unorderedEquals(chatIds ?? [], messageRecipients);
    } else {
      final chatIds = state.chatIds!;
      final messageRecipients = event.message.displayRecipient.recipients.map((recipient) => recipient.userId).toList();
      isThisChatMessage = unorderedEquals(chatIds.toList(), messageRecipients);
    }
    if (isThisChatMessage) {
      final updatedMessages = [...state.messages, event.message];
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  @override
  Future<void> close() {
    _typingEventsSubscription.cancel();
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    _reactionsSubscription.cancel();
    _deleteMessageSubscription.cancel();
    _updateMessageSubscription.cancel();
    _readMessageDebounceTimer?.cancel();
    return super.close();
  }
}
