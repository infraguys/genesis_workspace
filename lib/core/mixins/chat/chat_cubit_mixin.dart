import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/reaction_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_message_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_messages_flags_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/upload_file_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/reaction_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

mixin ChatCubitMixin<S extends Object> on Cubit<S> {
  UploadFileUseCase get uploadFileUseCase;
  UpdateMessagesFlagsUseCase get updateMessagesFlagsUseCase;
  UpdateMessageUseCase get updateMessageUseCase;

  List<UploadFileEntity> getUploadedFiles(S state);
  String getUploadedFilesString(S state);
  String? getUploadFileError(S state);
  String? getUploadFileErrorName(S state);
  List<MessageEntity> getStateMessages(S state);
  Set<int> getPendingToMarkAsRead(S state);
  List<EditingAttachment> getEditingAttachments(S state);

  S copyWithCommon({
    List<UploadFileEntity>? uploadedFiles,
    String? uploadedFilesString,
    String? uploadFileError,
    String? uploadFileErrorName,
    List<MessageEntity>? messages,
    List<EditingAttachment>? editingAttachments,
    bool? isEdited,
  });

  final Map<String, CancelToken> _uploadCancelTokens = <String, CancelToken>{};
  Timer? _readMessageDebounceTimer;

  //Upload files

  Future<void> uploadImagesCommon({
    List<XFile>? droppedImages,
    List<PlatformFile>? droppedPlatformImages,
  }) async {
    try {
      // 1) Если пришли PlatformFile — используем их напрямую
      final List<PlatformFile> platformFiles =
          (droppedPlatformImages != null && droppedPlatformImages.isNotEmpty)
          ? droppedPlatformImages
          : <PlatformFile>[];

      // 2) Если нет — тогда работаем с XFile (из picker)
      final List<XFile> xfiles = (platformFiles.isEmpty)
          ? (droppedImages ?? await pickImages())
          : const <XFile>[];

      if (platformFiles.isEmpty && xfiles.isEmpty) return;

      final List<Future<void>> uploadTasks = <Future<void>>[];

      // === ВЕТКА A: PlatformFile (вставка из clipboard/drag&drop) ===
      for (final PlatformFile platformfile in platformFiles) {
        final Uint8List bytes = platformfile.bytes ?? Uint8List(0);
        final int fileSize = bytes.isNotEmpty ? bytes.length : platformfile.size;
        final String localId = generateFileLocalId(platformfile.name);

        final UploadingFileEntity placeholder = UploadingFileEntity(
          localId: localId,
          filename: platformfile.name,
          size: fileSize,
          bytesSent: 0,
          bytesTotal: fileSize == 0 ? null : fileSize,
          type: UploadFileType.image,
          path: (platformfile.path != null && platformfile.path!.isNotEmpty)
              ? platformfile.path
              : null,
          bytes: bytes,
        );
        _addUploadingFile(placeholder);

        uploadTasks.add(
          _uploadSingleFileCommon(
            platformFile: PlatformFile(
              name: platformfile.name,
              size: fileSize,
              path: (platformfile.path != null && platformfile.path!.isNotEmpty)
                  ? platformfile.path
                  : null,
              bytes: bytes.isNotEmpty ? bytes : null,
            ),
            localId: localId,
            type: UploadFileType.image,
          ),
        );
      }

      // === ВЕТКА B: XFile (image_picker) ===
      for (final XFile x in xfiles) {
        final Uint8List bytes = await x.readAsBytes();
        final int fileSize = bytes.length;
        final String localId = generateFileLocalId(x.name);

        final UploadingFileEntity placeholder = UploadingFileEntity(
          localId: localId,
          filename: x.name,
          size: fileSize,
          bytesSent: 0,
          bytesTotal: fileSize == 0 ? null : fileSize,
          type: UploadFileType.image,
          path: (x.path.isNotEmpty) ? x.path : null, // НЕ ''
          bytes: bytes,
        );
        _addUploadingFile(placeholder);

        uploadTasks.add(
          _uploadSingleFileCommon(
            platformFile: PlatformFile(
              name: x.name,
              size: fileSize,
              path: (x.path.isNotEmpty) ? x.path : null,
              bytes: bytes,
            ),
            localId: localId,
            type: UploadFileType.image,
          ),
        );
      }

      await Future.wait(uploadTasks, eagerError: true);
    } catch (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);
    }
  }

  Future<void> uploadFilesCommon({List<PlatformFile>? droppedFiles}) async {
    final List<PlatformFile>? platformFiles = droppedFiles ?? await pickNonImageFiles();
    if (platformFiles == null || platformFiles.isEmpty) return;

    final List<Future<void>> uploadTasks = <Future<void>>[];

    for (final PlatformFile platformFile in platformFiles) {
      final String ext = extensionOf(platformFile.name).toLowerCase();
      if (AppConstants.kImageExtensions.contains(ext)) continue;

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
        _uploadSingleFileCommon(
          platformFile: platformFile,
          localId: localId,
          type: UploadFileType.file,
        ),
      );
    }

    if (uploadTasks.isEmpty) return;
    await Future.wait(uploadTasks, eagerError: true);
  }

  String? _guessImageMimeType(String fileName) {
    final String ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  XFile _xfileFromPlatformFile(PlatformFile platformFile) {
    if (platformFile.bytes != null) {
      final Uint8List data = platformFile.bytes!;
      return XFile.fromData(
        data,
        name: platformFile.name,
        length: data.length,
        mimeType: _guessImageMimeType(platformFile.name),
      );
    }
    if (platformFile.path != null && platformFile.path!.isNotEmpty) {
      return XFile(
        platformFile.path!,
        name: platformFile.name,
        // mimeType не обязателен
      );
    }
    throw StateError('PlatformFile "${platformFile.name}" не содержит ни bytes, ни path.');
  }

  Future<List<XFile>> _normalizeImages({
    List<XFile>? droppedImages,
    List<PlatformFile>? droppedPlatformImages,
  }) async {
    if (droppedImages != null && droppedImages.isNotEmpty) {
      return droppedImages;
    }
    if (droppedPlatformImages != null && droppedPlatformImages.isNotEmpty) {
      return droppedPlatformImages.map(_xfileFromPlatformFile).toList(growable: false);
    }
    return await pickImages();
  }

  Future<void> _uploadSingleFileCommon({
    required PlatformFile platformFile,
    required String localId,
    required UploadFileType type,
  }) async {
    final CancelToken cancelToken = CancelToken();
    _uploadCancelTokens[localId] = cancelToken;

    try {
      final UploadFileRequestEntity request = UploadFileRequestEntity(file: platformFile);

      final response = await uploadFileUseCase.call(
        request,
        cancelToken: cancelToken,
        onProgress: (int bytesSent, int bytesTotal) {
          if (!_uploadCancelTokens.containsKey(localId)) return;
          _updateProgress(localId, bytesSent, bytesTotal);
        },
      );

      if (!_uploadCancelTokens.containsKey(localId)) return;

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
        removeUploadedFileCommon(localId);
        return;
      }
      removeUploadedFileCommon(localId);
      final String? message = e.response?.data['message'];
      emit(copyWithCommon(uploadFileError: message, uploadFileErrorName: platformFile.name));
      rethrow;
    } catch (e, st) {
      removeUploadedFileCommon(localId);
      inspect(e);
      inspect(st);
    } finally {
      _uploadCancelTokens.remove(localId);
    }
  }

  void cancelUploadCommon(String localId) {
    final CancelToken? token = _uploadCancelTokens.remove(localId);
    token?.cancel('canceled_by_user:$localId');
    removeUploadedFileCommon(localId);
  }

  void clearUploadFileErrorCommon() {
    emit(copyWithCommon(uploadFileError: null, uploadFileErrorName: null));
  }

  void _addUploadingFile(UploadingFileEntity newItem) {
    final List<UploadFileEntity> next = List.of(getUploadedFiles(state))..add(newItem);
    emit(copyWithCommon(uploadedFiles: next));
  }

  void _updateProgress(String localId, int bytesSent, int bytesTotal) {
    final List<UploadFileEntity> next = getUploadedFiles(state).map((item) {
      if (item is UploadingFileEntity && item.localId == localId) {
        return item.copyWith(bytesSent: bytesSent, bytesTotal: bytesTotal);
      }
      return item;
    }).toList();
    emit(copyWithCommon(uploadedFiles: next));
  }

  void _replaceWithUploaded(String localId, UploadedFileEntity uploaded) {
    final List<UploadFileEntity> next = getUploadedFiles(state).map((item) {
      return item.localId == localId ? uploaded : item;
    }).toList();
    emit(copyWithCommon(uploadedFiles: next));
  }

  void removeUploadedFileCommon(String localId) {
    final List<UploadFileEntity> next = getUploadedFiles(
      state,
    ).where((item) => item.localId != localId).toList();
    emit(copyWithCommon(uploadedFiles: next));
  }

  //Update message

  Future<void> updateMessage({required int messageId, required String content}) async {
    try {
      final composed = buildMessageContent(content: content);
      await updateMessageUseCase.call(
        UpdateMessageRequestEntity(messageId: messageId, content: composed),
      );
      emit(
        copyWithCommon(
          uploadedFilesString: '',
          uploadedFiles: [],
          editingAttachments: [],
          isEdited: false,
        ),
      );
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  void cancelEdit() {
    emit(
      copyWithCommon(
        isEdited: false,
        editingAttachments: [],
        uploadedFilesString: '',
        uploadedFiles: [],
      ),
    );
  }

  void removeEditingAttachment(EditingAttachment attachment) {
    final updatedAttachments = [...getEditingAttachments(state)];
    updatedAttachments.remove(attachment);
    emit(copyWithCommon(editingAttachments: updatedAttachments, isEdited: true));
  }

  String buildMessageContent({
    required String content,
    bool placeFilesOnTop = true,
    bool stripExistingAttachmentsFromContent = true,
  }) {
    final editingAttachments = getEditingAttachments(state);
    final uploadedFiles = getUploadedFiles(state);

    final String trimmedContent = stripExistingAttachmentsFromContent
        ? extractMessageText(content)
        : content.trim();

    final List<String> editingLinks = editingAttachments
        .map((attachment) {
          final String raw = (attachment.rawString ?? '').trim();
          if (raw.isNotEmpty) return raw;
          return '[${attachment.filename}](${attachment.url})';
        })
        .where((link) => link.isNotEmpty)
        .toList();

    final List<String> uploadedLinks = uploadedFiles
        .whereType<UploadedFileEntity>()
        .map((file) => '[${file.filename}](${file.url})')
        .where((link) => link.isNotEmpty)
        .toList();

    final LinkedHashSet<String> uniqueFileLinks = LinkedHashSet<String>()
      ..addAll(editingLinks)
      ..addAll(uploadedLinks);

    final List<String> nonEmptyParts = [];

    if (placeFilesOnTop) {
      if (uniqueFileLinks.isNotEmpty) nonEmptyParts.addAll(uniqueFileLinks);
      if (trimmedContent.isNotEmpty) nonEmptyParts.add(trimmedContent);
    } else {
      if (trimmedContent.isNotEmpty) nonEmptyParts.add(trimmedContent);
      if (uniqueFileLinks.isNotEmpty) nonEmptyParts.addAll(uniqueFileLinks);
    }

    return nonEmptyParts.join('\n');
  }

  List<EditingAttachment> parseAttachments(String content) {
    final RegExp pattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final Iterable<RegExpMatch> matches = pattern.allMatches(content);

    final List<EditingAttachment> attachments = matches.map((match) {
      final String rawString = match.group(0)!;
      final String filename = match.group(1)!;
      final String extension = filename.split('.').last;
      final String url = match.group(2)!;

      final UploadFileType type = AppConstants.kImageExtensions.contains(extension)
          ? UploadFileType.image
          : UploadFileType.file;

      return EditingAttachment(
        filename: filename,
        extension: extension,
        url: url,
        type: type,
        rawString: rawString,
      );
    }).toList();

    return attachments;
  }

  void setUploadedFiles(String content) {
    List<EditingAttachment> attachments = parseAttachments(content);
    emit(copyWithCommon(editingAttachments: attachments));
  }

  //Read message
  void scheduleMarkAsReadCommon(int messageId) {
    final Set<int> bucket = getPendingToMarkAsRead(state);
    bucket.add(messageId);

    final List<MessageEntity> current = List.of(getStateMessages(state));
    final int index = current.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final MessageEntity message = current[index];
      final List<String> nextFlags = [...?message.flags, MessageFlag.read.name];
      current[index] = message.copyWith(flags: nextFlags);
      emit(copyWithCommon(messages: current));
    }

    _readMessageDebounceTimer?.cancel();
    _readMessageDebounceTimer = Timer(const Duration(milliseconds: 500), _sendMarkAsReadCommon);
  }

  Future<void> _sendMarkAsReadCommon() async {
    final Set<int> pending = getPendingToMarkAsRead(state);
    if (pending.isEmpty) return;

    final List<int> ids = pending.toList();
    pending.clear();

    try {
      await updateMessagesFlagsUseCase.call(
        UpdateMessagesFlagsRequestEntity(
          messages: ids,
          op: UpdateMessageFlagsOp.add,
          flag: MessageFlag.read,
        ),
      );
    } catch (_) {
      // no-op
    }
  }

  //Events handlers

  void onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    final List<MessageEntity> current = List.of(getStateMessages(state));
    bool changed = false;

    for (final int messageId in event.messages) {
      final int index = current.indexWhere((m) => m.id == messageId);
      if (index == -1) continue;

      final MessageEntity message = current[index];

      if (event.flag == MessageFlag.read) {
        final MessageEntity updated = message.copyWith(
          flags: [...message.flags ?? <String>[], MessageFlag.read.name],
        );
        current[index] = updated;
        changed = true;
      } else if (event.flag == MessageFlag.starred) {
        if (event.op == UpdateMessageFlagsOp.add) {
          final MessageEntity updated = message.copyWith(
            flags: [...message.flags ?? <String>[], MessageFlag.starred.name],
          );
          current[index] = updated;
        } else if (event.op == UpdateMessageFlagsOp.remove) {
          final List<String> nextFlags = [...?message.flags]..remove(MessageFlag.starred.name);
          final MessageEntity updated = message.copyWith(flags: nextFlags);
          current[index] = updated;
        }
        changed = true;
      }
    }

    if (changed) {
      emit(copyWithCommon(messages: current));
    }
  }

  void onReactionEvents(ReactionEventEntity event) {
    final List<MessageEntity> current = List.of(getStateMessages(state));
    final int index = current.indexWhere((m) => m.id == event.messageId);
    if (index == -1) return;

    final MessageEntity message = current[index];
    final List<ReactionEntity> reactions = List.of(message.reactions);

    if (event.op == ReactionOp.add) {
      reactions.add(
        ReactionEntity(
          emojiName: event.emojiName,
          emojiCode: event.emojiCode,
          reactionType: event.reactionType,
          userId: event.userId,
        ),
      );
    } else {
      reactions.removeWhere((r) => r.userId == event.userId && r.emojiName == event.emojiName);
    }

    current[index] = message.copyWith(reactions: reactions);
    emit(copyWithCommon(messages: current));
  }

  void onDeleteMessageEvents(DeleteMessageEventEntity event) {
    final List<MessageEntity> next = List.of(getStateMessages(state))
      ..removeWhere((m) => m.id == event.messageId);
    emit(copyWithCommon(messages: next));
  }

  void onUpdateMessageEvents(UpdateMessageEventEntity event) {
    final updatedMessages = [...getStateMessages(state)];
    final int index = updatedMessages.indexWhere((m) => m.id == event.messageId);
    if (index != -1) {
      final MessageEntity message = updatedMessages[index];
      updatedMessages[index] = message.copyWith(content: event.renderedContent);
      emit(copyWithCommon(messages: updatedMessages));
    }
  }

  void disposeCommon() {
    _readMessageDebounceTimer?.cancel();
    _uploadCancelTokens.clear();
  }
}
