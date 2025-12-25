import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/data/messages/api/messages_api_client.dart';
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart';
import 'package:genesis_workspace/data/messages/dto/delete_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/emoji_reaction_dto.dart';
import 'package:genesis_workspace/data/messages/dto/mark_as_read_dto.dart';
import 'package:genesis_workspace/data/messages/dto/message_readers_response.dart';
import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/send_message_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/single_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_messages_flags_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';
import 'package:genesis_workspace/data/messages/tus/platform_chunk_reader.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';

@Injectable(as: MessagesDataSource)
class MessagesDataSourceImpl implements MessagesDataSource {
  final MessagesApiClient apiClient = MessagesApiClient(getIt<Dio>());
  final Dio dio = getIt<Dio>();

  @override
  Future<MessagesResponseDto> getMessages(MessagesRequestDto body) async {
    try {
      final anchor = body.anchor;
      final narrowString = jsonEncode(body.narrow?.map((e) => e.toJson()).toList());
      final bool applyMarkdown = body.applyMarkdown;
      final bool clientGravatar = body.clientGravatar;
      final bool includeAnchor = body.includeAnchor;

      return await apiClient.getMessages(
        anchor,
        narrowString,
        body.numBefore,
        body.numAfter,
        applyMarkdown,
        clientGravatar,
        includeAnchor,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SingleMessageResponseDto> getMessageById(SingleMessageRequestDto body) async {
    try {
      final messageId = body.messageId;
      final applyMarkdown = body.applyMarkdown;
      return await apiClient.getMessageById(messageId, applyMarkdown);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(SendMessageRequestDto body) async {
    try {
      final readBySender = true;
      await apiClient.sendMessage(
        body.type,
        jsonEncode(body.to),
        body.content,
        body.streamId,
        body.topic,
        readBySender,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMessagesFlags(UpdateMessagesFlagsRequestDto body) async {
    try {
      await apiClient.updateMessagesFlags(jsonEncode(body.messages), body.op, body.flag);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmojiReactionResponseDto> addEmojiReaction(EmojiReactionRequestDto body) async {
    try {
      return await apiClient.addEmojiReaction(body.messageId, body.emojiName);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmojiReactionResponseDto> removeEmojiReaction(EmojiReactionRequestDto body) async {
    try {
      return await apiClient.removeEmojiReaction(body.messageId, body.emojiName);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DeleteMessageResponseDto> deleteMessage(DeleteMessageRequestDto body) async {
    try {
      return await apiClient.deleteMessage(body.messageId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UpdateMessageResponseDto> updateMessage(UpdateMessageRequestDto body) async {
    try {
      final response = await apiClient.updateMessage(body.messageId, body.content);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UploadFileResponseDto> uploadFile(
    UploadFileRequestDto body, {
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final FormData formData = FormData();
      final MultipartFile part = (kIsWeb || body.file.path == null || body.file.path!.isEmpty)
          ? MultipartFile.fromBytes(body.file.bytes!, filename: body.file.name)
          : await MultipartFile.fromFile(body.file.path ?? '', filename: body.file.name);
      formData.files.add(MapEntry('file', part));

      const int fifteenMB = 15 * 1024 * 1024;
      final bool isLargeFile = formData.files.any((e) => e.value.length > fifteenMB);

      if (isLargeFile) {
        final PlatformChunkReader reader = createPlatformChunkReader(body);
        await reader.open();
        try {
          final int fileSize = await reader.length();
          final UploadFileResponseDto result = await _uploadViaTus(
            fileName: body.file.name,
            fileSize: fileSize,
            reader: reader,
            onProgress: onProgress,
            cancelToken: cancelToken,
          );
          return result;
        } finally {
          await reader.close();
        }
      } else {
        return await apiClient.uploadFile(formData, onProgress, cancelToken);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UploadFileResponseDto> _uploadViaTus({
    required String fileName,
    required int fileSize,
    required PlatformChunkReader reader,
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final String metadata = _buildTusMetadata(
      filename: fileName,
      mimeType: lookupMimeType(fileName),
    );

    final create = await apiClient.createUpload(fileSize.toString(), metadata);

    final String? location = create.response.headers.value('location') ?? create.response.headers.value('Location');
    if (location == null) {
      throw StateError('TUS: Location header is missing');
    }
    final String uploadUrl = _resolveLocation(location);

    int offset = await _tusHead(uploadUrl, cancelToken);

    const int chunkSize = 5 * 1024 * 1024;
    while (offset < fileSize) {
      final int toRead = min(chunkSize, fileSize - offset);
      final List<int> chunk = await reader.read(offset, toRead); // было: Uint8List
      await _tusPatch(
        uploadUrl,
        chunk,
        offset,
        cancelToken,
        (sent, total) => onProgress?.call(offset + sent, fileSize),
      );
      offset += chunk.length;
      onProgress?.call(offset, fileSize);
    }

    final _AttachmentMatch match = await _findInAttachments(
      expectedName: fileName,
      expectedSize: fileSize,
      cancelToken: cancelToken,
    );

    return UploadFileResponseDto(
      filename: match.filename,
      url: '/user_uploads/${match.pathId}',
      uri: '/user_uploads/${match.pathId}',
      result: 'success',
      msg: '',
    );
  }

  String _resolveLocation(String locationHeader) {
    final String base = dio.options.baseUrl;
    if (locationHeader.startsWith('http://') || locationHeader.startsWith('https://')) {
      return locationHeader;
    }
    if (base.isEmpty) return locationHeader;
    return Uri.parse(base).resolve(locationHeader).toString();
  }

  Future<_AttachmentMatch> _findInAttachments({
    required String expectedName,
    required int expectedSize,
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> res = await dio.get<Map<String, dynamic>>(
      '/attachments',
      cancelToken: cancelToken,
    );

    final List<dynamic> items = (res.data?['attachments'] as List<dynamic>? ?? <dynamic>[]);
    _AttachmentMatch? best;
    for (final dynamic raw in items) {
      final map = raw as Map<String, dynamic>;
      final String name = map['name'] as String? ?? '';
      final int size = map['size'] as int? ?? -1;
      final String pathId = map['path_id'] as String? ?? '';
      final int ts = map['create_time'] as int? ?? 0;
      if (name == expectedName && size == expectedSize) {
        if (best == null || ts > best!.createTime) {
          best = _AttachmentMatch(filename: name, pathId: pathId, createTime: ts);
        }
      }
    }
    if (best == null) {
      throw StateError('TUS: uploaded file not found in attachments');
    }
    return best!;
  }

  Future<int> _tusHead(String uploadUrl, CancelToken? cancelToken) async {
    final Response res = await dio.head(
      uploadUrl,
      options: Options(headers: {'Tus-Resumable': AppConstants.tusVersion}),
      cancelToken: cancelToken,
    );
    final String value = res.headers.value('Upload-Offset') ?? res.headers.value('upload-offset') ?? '0';
    return int.parse(value);
  }

  Future<void> _tusPatch(
    String uploadUrl,
    List<int> chunk,
    int offset,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  ) async {
    await dio.patch(
      uploadUrl,
      data: chunk,
      options: Options(
        headers: {
          'Tus-Resumable': AppConstants.tusVersion,
          'Upload-Offset': offset.toString(),
          'Content-Type': 'application/offset+octet-stream',
          'Content-Length': chunk.length.toString(),
        },
        responseType: ResponseType.plain,
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  String _buildTusMetadata({required String filename, String? mimeType}) {
    final parts = <String>[
      'filename ${b64(filename)}',
      if (mimeType != null) 'type ${b64(mimeType)}',
    ];
    return parts.join(',');
  }

  @override
  Future<MessageReadersResponse> getMessageReaders(int messageId) async {
    try {
      return await apiClient.getMessageReaders(messageId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markStreamAsRead(MarkStreamAsReadRequestDto body) async {
    try {
      await apiClient.markStreamAsRead(body.streamId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markTopicAsRead(MarkTopicAsReadRequestDto body) async {
    try {
      await apiClient.markTopicAsRead(body.streamId, body.topicName);
    } catch (e) {
      rethrow;
    }
  }
}

class _AttachmentMatch {
  final String filename;
  final String pathId;
  final int createTime;
  _AttachmentMatch({required this.filename, required this.pathId, required this.createTime});
}
