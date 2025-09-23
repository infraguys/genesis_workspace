import 'dart:async';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/web_drop_types.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/services/paste/paste_capture_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_clipboard/super_clipboard.dart';

abstract class ChatCubitCapable {
  Future<void> changeTyping({required TypingEventOp op});
  void setIsMessagePending(bool value);
  Future<void> updateMessage({required int messageId, required String content});
  void setUploadedFiles(String content);
  void removeEditingAttachment(EditingAttachment attachment);
  void cancelEdit();
  Future<void> uploadFilesCommon({List<PlatformFile>? droppedFiles});
  Future<void> uploadImagesCommon({
    List<XFile>? droppedImages,
    List<PlatformFile> droppedPlatformImages,
  });
}

class ChatPasteAction extends Action<PasteTextIntent> {
  ChatPasteAction({required this.onPaste});
  final Future<void> Function() onPaste;

  @override
  Future<Object?> invoke(PasteTextIntent intent) async {
    await onPaste();
    return null;
  }
}

mixin ChatWidgetMixin<TChatCubit extends ChatCubitCapable, TWidget extends StatefulWidget>
    on State<TWidget> {
  late final TextEditingController messageController;
  final FocusNode messageInputFocusNode = FocusNode();
  final PasteCaptureService pasteCaptureService = getIt<PasteCaptureService>();

  String currentText = '';
  bool isEditMode = false;
  MessageEntity? editingMessage;
  final events = ClipboardEvents.instance;

  bool isDropOver = false;
  final GlobalKey dropAreaKey = GlobalKey();
  RemoveDropHandlers? removeWebDnD;

  @mustCallSuper
  void initChatInputEditMixin() {
    messageController.addListener(_handleTextChanged);
  }

  @mustCallSuper
  void disposeChatInputEditMixin() {
    messageController.removeListener(_handleTextChanged);
    messageController.dispose();
    messageInputFocusNode.dispose();
  }

  Future<void> onTextChanged() async {
    setState(() {
      currentText = messageController.text;
    });
  }

  Future<void> _handleTextChanged() async {
    setState(() => currentText = messageController.text);
    await context.read<TChatCubit>().changeTyping(
      op: currentText.trim().isEmpty ? TypingEventOp.stop : TypingEventOp.start,
    );
  }

  //Quote message

  Future<void> onTapQuote(int messageId) async {
    try {
      context.read<TChatCubit>().setIsMessagePending(true);

      final singleMessage = await context.read<MessagesCubit>().getMessageById(
        messageId: messageId,
        applyMarkdown: false,
      );

      final String quote = generateMessageQuote(singleMessage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        insertQuoteAndFocus(textToInsert: quote);
      });
    } catch (e) {
      inspect(e);
    } finally {
      context.read<TChatCubit>().setIsMessagePending(false);
    }
  }

  void insertQuoteAndFocus({required String textToInsert, bool append = false}) {
    final String existingText = messageController.text;
    final String nextText = append && existingText.isNotEmpty
        ? '$existingText\n$textToInsert'
        : textToInsert;

    messageController.text = nextText;
    messageController.selection = TextSelection.collapsed(offset: nextText.length);
    messageInputFocusNode.requestFocus();
  }

  Future<void> quoteMessageById({
    required int messageId,
    required String Function(MessageEntity) quoteBuilder,
    required Future<void> Function(bool isPending) setPending,
  }) async {
    try {
      await setPending(true);
      final MessageEntity message = await context.read<MessagesCubit>().getMessageById(
        messageId: messageId,
        applyMarkdown: false,
      );
      final String quote = quoteBuilder(message);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        insertQuoteAndFocus(textToInsert: quote);
      });
    } finally {
      await setPending(false);
    }
  }

  //Edit message

  Future<void> onTapEditMessage(UpdateMessageRequestEntity body) async {
    try {
      context.read<TChatCubit>().setIsMessagePending(true);
      final MessageEntity message = await context.read<MessagesCubit>().getMessageById(
        messageId: body.messageId,
        applyMarkdown: false,
      );
      final messageBody = extractMessageText(message.content);
      setState(() {
        isEditMode = true;
        editingMessage = message.copyWith(content: messageBody);
      });
      context.read<TChatCubit>().setUploadedFiles(message.content);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messageController.text = messageBody;
        messageController.selection = TextSelection.collapsed(offset: messageBody.length);
        messageInputFocusNode.requestFocus();
      });
    } finally {
      context.read<TChatCubit>().setIsMessagePending(false);
    }
  }

  void onCancelEdit() {
    context.read<TChatCubit>().cancelEdit();
    context.read<TChatCubit>().setIsMessagePending(false);
    setState(() {
      isEditMode = false;
      editingMessage = null;
      messageController.clear();
    });
  }

  Future<void> submitEdit() async {
    context.read<TChatCubit>().setIsMessagePending(true);
    if (editingMessage == null) return;
    try {
      final String newContent = messageController.text;
      await context.read<TChatCubit>().updateMessage(
        messageId: editingMessage!.id,
        content: newContent,
      );
      setState(() {
        messageController.clear();
        isEditMode = false;
        editingMessage = null;
      });
    } catch (e) {
      rethrow;
    } finally {
      if (context.mounted) {
        context.read<TChatCubit>().setIsMessagePending(false);
      }
    }
  }

  // Paste files
  Future<void> onPasteFiles(List<PlatformFile>? files) async {
    await context.read<TChatCubit>().uploadFilesCommon(droppedFiles: files);
  }

  // Paste files
  Future<void> onPasteImage(List<PlatformFile>? files) async {
    await context.read<TChatCubit>().uploadImagesCommon(droppedPlatformImages: files ?? []);
  }

  void handleCaptured(dynamic captured) {
    switch (captured.runtimeType) {
      case String:
        messageController.text = '${messageController.text}$captured';
        break;

      case PlatformFile:
        final PlatformFile platformFile = captured as PlatformFile;
        final extension = extensionOf(platformFile.name).toLowerCase();
        if (isImageExtension(extension)) {
          unawaited(onPasteImage([platformFile]));
        } else {
          unawaited(onPasteFiles([platformFile]));
        }
        break;

      default:
        print('Unknown type: ${captured.runtimeType}');
    }
  }
}
