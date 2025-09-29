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
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_presence_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/set_typing_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState>
    with ChatCubitMixin<ChatState>
    implements ChatCubitCapable {
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
          chatId: null,
          typingId: null,
          myUserId: null,
          isMessagePending: false,
          isLoadingMore: false,
          isAllMessagesLoaded: false,
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
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      onMessageFlagsEvents,
    );
    _reactionsSubscription = _realTimeService.reactionsEventsStream.listen(onReactionEvents);
    _deleteMessageSubscription = _realTimeService.deleteMessageEventsStream.listen(
      onDeleteMessageEvents,
    );
    _updateMessageSubscription = _realTimeService.updateMessageEventsStream.listen(
      onUpdateMessageEvents,
    );
  }

  final RealTimeService _realTimeService;

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

  Future<void> getInitialData({
    required int userId,
    required int myUserId,
    int? unreadMessagesCount,
  }) async {
    state.chatId = userId;
    try {
      final UserEntity user = await _getUserByIdUseCase.call(userId);
      final presence = await _getUserPresenceUseCase.call(userId);
      final DmUserEntity dmUser = user.toDmUser();
      dmUser.presenceStatus = presence.userPresence.aggregated!.status;
      dmUser.presenceTimestamp = presence.userPresence.aggregated!.timestamp;
      emit(state.copyWith(userEntity: dmUser));
      await getMessages(myUserId: myUserId, unreadMessagesCount: unreadMessagesCount);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getMessages({required int myUserId, int? unreadMessagesCount}) async {
    state.myUserId = myUserId;
    int numBefore = 25;
    if (unreadMessagesCount != null && unreadMessagesCount > numBefore) {
      numBefore = unreadMessagesCount + 5;
    }

    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [
          MessageNarrowEntity(operator: NarrowOperator.dm, operand: [state.userEntity!.userId]),
        ],
        numBefore: numBefore,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(body);
      if (response.messages.isNotEmpty) {
        state.lastMessageId = response.messages.first.id;
        state.messages = response.messages;
      }
      emit(state.copyWith(messages: state.messages, isAllMessagesLoaded: response.foundOldest));
    } catch (e) {
      inspect(e);
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
            MessageNarrowEntity(operator: NarrowOperator.dm, operand: [state.chatId ?? 0]),
          ],
          numBefore: 25,
          numAfter: 0,
        );
        final response = await _getMessagesUseCase.call(body);
        state.lastMessageId = response.messages.first.id;
        state.isAllMessagesLoaded = response.foundOldest;
        state.messages = [...response.messages, ...state.messages];
        state.isLoadingMore = false;
        emit(
          state.copyWith(
            messages: state.messages,
            isLoadingMore: state.isLoadingMore,
            isAllMessagesLoaded: state.isAllMessagesLoaded,
          ),
        );
      } catch (e) {
        inspect(e);
      }
    }
  }

  @override
  Future<void> changeTyping({required TypingEventOp op}) async {
    if (state.selfTypingOp != op) {
      state.selfTypingOp = op;
      try {
        await _setTypingUseCase.call(
          TypingRequestEntity(type: SendMessageType.direct, op: op, to: [state.userEntity!.userId]),
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

  Future<void> sendMessage({required int chatId, required String content}) async {
    emit(state.copyWith(isMessagePending: true));
    final String composed = buildMessageContent(content: content);

    final body = SendMessageRequestEntity(
      type: SendMessageType.direct,
      to: [chatId],
      content: composed,
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

  void _onTypingEvents(TypingEventEntity event) {
    final senderId = event.sender.userId;
    final isWriting = event.op == TypingEventOp.start && senderId == state.chatId;

    if (isWriting) {
      state.typingId = senderId;
    } else {
      state.typingId = null;
    }
    emit(state.copyWith(typingId: state.typingId));
  }

  void _onMessageEvents(MessageEventEntity event) {
    bool isThisChatMessage =
        event.message.displayRecipient.any((recipient) => recipient.userId == state.myUserId) &&
        event.message.displayRecipient.any((recipient) => recipient.userId == state.chatId);
    if (isThisChatMessage) {
      state.messages = [...state.messages, event.message];
      emit(state.copyWith(messages: state.messages));
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
