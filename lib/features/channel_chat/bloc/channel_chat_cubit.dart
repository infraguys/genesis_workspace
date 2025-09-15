import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/reaction_op.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/send_message_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_messages_flags_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/upload_file_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/reaction_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/channel_by_id_entity.dart';
import 'package:genesis_workspace/domain/users/entities/stream_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_channel_by_id_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/set_typing_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

part 'channel_chat_state.dart';

@injectable
class ChannelChatCubit extends Cubit<ChannelChatState> {
  ChannelChatCubit(
    this._realTimeService,
    this._getMessagesUseCase,
    this._setTypingUseCase,
    this._updateMessagesFlagsUseCase,
    this._sendMessageUseCase,
    this._getChannelByIdUseCase,
    this._getTopicsUseCase,
    this._uploadFileUseCase,
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
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
    _reactionsSubscription = _realTimeService.reactionsEventsStream.listen(_onReactionEvents);
    _deleteMessageEventsSubscription = _realTimeService.deleteMessageEventsStream.listen(
      _onDeleteMessageEvents,
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

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsSubscription;
  late final StreamSubscription<ReactionEventEntity> _reactionsSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageEventsSubscription;

  Timer? _readMessageDebounceTimer;

  final Map<String, CancelToken> _uploadCancelTokens = <String, CancelToken>{};

  Future<void> getInitialData({
    required int streamId,
    String? topicName,
    bool? didUpdateWidget,
    int? unreadMessagesCount,
  }) async {
    emit(state.copyWith(channel: null, topic: null, messages: []));
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
      emit(state.copyWith(channel: channel));
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
      emit(
        state.copyWith(
          messages: response.messages,
          isAllMessagesLoaded: response.foundOldest,
          lastMessageId: response.messages.first.id,
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

  Future<void> sendMessage({required int streamId, required String content, String? topic}) async {
    emit(state.copyWith(isMessagePending: true));
    final SendMessageType type = SendMessageType.stream;
    for (var file in state.uploadedFiles) {
      if (file is UploadedFileEntity) {
        final uploaded = file;
        final String fileLink = '[${uploaded.filename}](${uploaded.url})';
        final String newUploadedFilesString = appendFileLink(state.uploadedFilesString, fileLink);

        emit(state.copyWith(uploadedFilesString: newUploadedFilesString));
      }
    }
    final messageParts = [state.uploadedFilesString, content].where((part) => part.isNotEmpty);
    final body = SendMessageRequestEntity(
      type: type,
      to: [streamId],
      content: messageParts.join('\n'),
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

  Future<void> uploadImage() async {
    try {
      final List<XFile> images = await pickImages();
      if (images.isEmpty) return;

      final List<Future<void>> uploadTasks = <Future<void>>[];

      for (final XFile image in images) {
        final int size = await image.length();
        final String localId = generateFileLocalId(image.name);

        final bytes = await image.readAsBytes();

        final UploadingFileEntity placeholder = UploadingFileEntity(
          localId: localId,
          filename: image.name,
          size: size,
          bytesSent: 0,
          bytesTotal: size == 0 ? null : size,
          type: UploadFileType.image,
          path: image.path,
          bytes: bytes,
        );
        _addUploadingFile(placeholder);

        uploadTasks.add(_uploadSingleImage(imageFile: image, localId: localId));
      }

      await Future.wait(uploadTasks, eagerError: true);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> _uploadSingleImage({required XFile imageFile, required String localId}) async {
    final int fileSize = await imageFile.length();

    final PlatformFile platformFile = PlatformFile(
      name: imageFile.name,
      size: fileSize,
      path: imageFile.path,
      bytes: await imageFile.readAsBytes(),
    );

    return _uploadSingleFile(
      platformFile: platformFile,
      localId: localId,
      type: UploadFileType.image,
    );
  }

  Future<void> uploadFiles() async {
    final List<PlatformFile>? platformFiles = await pickNonImageFiles();
    if (platformFiles == null || platformFiles.isEmpty) return;

    final List<Future<void>> uploadTasks = <Future<void>>[];

    for (final PlatformFile platformFile in platformFiles) {
      final String extension = extensionOf(platformFile.name).toLowerCase();
      if (AppConstants.kImageExtensions.contains(extension)) return;

      final String localId = generateFileLocalId(platformFile.name);

      final UploadingFileEntity placeholder = UploadingFileEntity(
        localId: localId,
        filename: platformFile.name,
        size: platformFile.size,
        bytesSent: 0,
        bytesTotal: platformFile.size == 0 ? null : platformFile.size,
        type: UploadFileType.file,
        path: platformFile.path ?? '',
        bytes: platformFile.bytes ?? Uint8List(0),
      );
      _addUploadingFile(placeholder);

      uploadTasks.add(
        _uploadSingleFile(platformFile: platformFile, localId: localId, type: UploadFileType.file),
      );
    }

    if (uploadTasks.isEmpty) return;

    await Future.wait(uploadTasks, eagerError: true);
  }

  Future<void> _uploadSingleFile({
    required PlatformFile platformFile,
    required String localId,
    required UploadFileType type,
  }) async {
    final CancelToken cancelToken = CancelToken();
    _uploadCancelTokens[localId] = cancelToken;

    try {
      final UploadFileRequestEntity request = UploadFileRequestEntity(file: platformFile);

      final response = await _uploadFileUseCase.call(
        request,
        cancelToken: cancelToken,
        onProgress: (int bytesSent, int bytesTotal) {
          if (!_uploadCancelTokens.containsKey(localId)) return;
          _updateProgress(localId, bytesSent, bytesTotal);
        },
      );

      if (!_uploadCancelTokens.containsKey(localId)) return; // отменили в процессе

      final UploadedFileEntity uploaded = response.toUploadedFileEntity(
        localId: localId,
        size: platformFile.size,
        type: type,
        path: platformFile.path ?? '',
        bytes: platformFile.bytes ?? Uint8List(0),
      );
      _replaceWithUploaded(localId, uploaded);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        removeUploadedFile(localId);
        return;
      }
      removeUploadedFile(localId);
      final errorMessage = e.response?.data['message'];
      emit(state.copyWith(uploadFileError: errorMessage, uploadFileErrorName: platformFile.name));
      rethrow;
    } catch (e, stackTrace) {
      removeUploadedFile(localId);
      inspect(e);
      inspect(stackTrace);
    } finally {
      _uploadCancelTokens.remove(localId);
    }
  }

  void clearUploadFileError() {
    state.uploadFileError = null;
    state.uploadFileErrorName = null;
    emit(
      state.copyWith(
        uploadFileError: state.uploadFileError,
        uploadFileErrorName: state.uploadFileErrorName,
      ),
    );
  }

  void cancelUpload(String localId) {
    final CancelToken? token = _uploadCancelTokens.remove(localId);
    token?.cancel('canceled_by_user:$localId');
    removeUploadedFile(localId);
  }

  void _addUploadingFile(UploadingFileEntity newItem) {
    final List<UploadFileEntity> next = List.of(state.uploadedFiles)..add(newItem);
    emit(state.copyWith(uploadedFiles: next));
  }

  void _updateProgress(String localId, int bytesSent, int bytesTotal) {
    final List<UploadFileEntity> next = state.uploadedFiles.map((UploadFileEntity item) {
      if (item is UploadingFileEntity && item.localId == localId) {
        return item.copyWith(bytesSent: bytesSent, bytesTotal: bytesTotal);
      }
      return item;
    }).toList();
    emit(state.copyWith(uploadedFiles: next));
  }

  void _replaceWithUploaded(String localId, UploadedFileEntity uploaded) {
    final List<UploadFileEntity> next = state.uploadedFiles.map((UploadFileEntity item) {
      return item.localId == localId ? uploaded : item;
    }).toList();
    emit(state.copyWith(uploadedFiles: next));
  }

  void removeUploadedFile(String localId) {
    final List<UploadFileEntity> next = state.uploadedFiles
        .where((item) => item.localId != localId)
        .toList();
    emit(state.copyWith(uploadedFiles: next));
  }

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

  void setIsMessagePending(bool value) {
    emit(state.copyWith(isMessagePending: value));
  }

  void scheduleMarkAsRead(int messageId) {
    state.pendingToMarkAsRead.add(messageId);
    final MessageEntity message = state.messages.firstWhere((message) => message.id == messageId);
    final indexOf = state.messages.indexOf(message);
    if (message.flags != null) {
      message.flags!.add(MessageFlag.read.name);
    } else {
      message.flags = [MessageFlag.read.name];
    }
    final newMessages = [...state.messages];
    newMessages[indexOf] = message;
    emit(state.copyWith(messages: newMessages));
    _readMessageDebounceTimer?.cancel();
    _readMessageDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _sendMarkAsRead();
    });
  }

  Future<void> _sendMarkAsRead() async {
    if (state.pendingToMarkAsRead.isEmpty) return;

    final idsToSend = state.pendingToMarkAsRead.toList();
    state.pendingToMarkAsRead.clear();

    try {
      await _updateMessagesFlagsUseCase.call(
        UpdateMessagesFlagsRequestEntity(
          messages: idsToSend,
          op: UpdateMessageFlagsOp.add,
          flag: MessageFlag.read,
        ),
      );
    } catch (e) {
      // Optional: retry or log error
    }
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

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    for (var messageId in event.messages) {
      if (event.flag == MessageFlag.read) {
        MessageEntity message = state.messages.firstWhere((message) => message.id == messageId);
        final int index = state.messages.indexOf(message);
        MessageEntity changedMessage = message.copyWith(
          flags: [...message.flags ?? [], MessageFlag.read.name],
        );
        state.messages[index] = changedMessage;
      }
      if (event.flag == MessageFlag.starred) {
        MessageEntity message = state.messages.firstWhere((message) => message.id == messageId);
        final int index = state.messages.indexOf(message);
        if (event.op == UpdateMessageFlagsOp.add) {
          MessageEntity changedMessage = message.copyWith(
            flags: [...message.flags ?? [], MessageFlag.starred.name],
          );
          state.messages[index] = changedMessage;
        } else if (event.op == UpdateMessageFlagsOp.remove) {
          MessageEntity changedMessage = message;
          changedMessage.flags?.remove(MessageFlag.starred.name);
          state.messages[index] = changedMessage;
        }
      }
    }
    emit(state.copyWith(messages: state.messages));
  }

  void _onReactionEvents(ReactionEventEntity event) {
    MessageEntity message = state.messages.firstWhere((message) => message.id == event.messageId);
    final int index = state.messages.indexOf(message);
    List<ReactionEntity> reactions = message.reactions;
    if (event.op == ReactionOp.add) {
      reactions.add(
        ReactionEntity(
          emojiName: event.emojiName,
          emojiCode: event.emojiCode,
          reactionType: event.reactionType,
          userId: event.userId,
        ),
      );
    } else if (event.op == ReactionOp.remove) {
      reactions.removeWhere(
        (reaction) => (reaction.userId == event.userId) && (reaction.emojiName == event.emojiName),
      );
    }
    MessageEntity changedMessage = message.copyWith(reactions: reactions);
    state.messages[index] = changedMessage;
    emit(state.copyWith(messages: state.messages));
  }

  void _onDeleteMessageEvents(DeleteMessageEventEntity event) {
    final updatedMessages = [...state.messages];
    updatedMessages.removeWhere((message) => message.id == event.messageId);
    emit(state.copyWith(messages: updatedMessages));
  }

  @override
  Future<void> close() {
    _typingEventsSubscription.cancel();
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    _readMessageDebounceTimer?.cancel();
    _reactionsSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    return super.close();
  }
}
