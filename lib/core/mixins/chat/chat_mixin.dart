import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/web_drop_types.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';

abstract class TypingCapable {
  Future<void> changeTyping({required TypingEventOp op});
  void setIsMessagePending(bool value);
}

mixin ChatMixin<TChatCubit extends TypingCapable, TWidget extends StatefulWidget>
    on State<TWidget> {
  late final TextEditingController messageController;
  final FocusNode messageInputFocusNode = FocusNode();

  String currentText = '';
  bool isEditMode = false;
  MessageEntity? editingMessage;

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
    } finally {
      context.read<TChatCubit>().setIsMessagePending(false);
    }
  }

  Future<void> _handleTextChanged() async {
    setState(() => currentText = messageController.text);
    await context.read<TChatCubit>().changeTyping(
      op: currentText.trim().isEmpty ? TypingEventOp.stop : TypingEventOp.start,
    );
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

  Future<void> startEditByMessageId({
    required int messageId,
    required Future<void> Function(bool isPending) setPending,
  }) async {
    try {
      await setPending(true);
      final MessageEntity message = await context.read<MessagesCubit>().getMessageById(
        messageId: messageId,
        applyMarkdown: false,
      );
      setState(() {
        isEditMode = true;
        editingMessage = message;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messageController.text = message.content;
        messageController.selection = TextSelection.collapsed(offset: message.content.length);
        messageInputFocusNode.requestFocus();
      });
    } finally {
      await setPending(false);
    }
  }

  void onCancelEdit() {
    setState(() {
      isEditMode = false;
      editingMessage = null;
      messageController.clear();
    });
  }

  Future<void> onTapEditMessage(UpdateMessageRequestEntity body) async {
    await startEditByMessageId(
      messageId: body.messageId,
      setPending: (pending) async => context.read<TChatCubit>().setIsMessagePending(pending),
    );
  }

  Future<void> submitEdit() async {
    context.read<TChatCubit>().setIsMessagePending(true);
    if (editingMessage == null) return;
    final String newContent = messageController.text;
    await context.read<MessagesCubit>().updateMessage(
      messageId: editingMessage!.id,
      content: newContent,
    );
    setState(() {
      messageController.clear();
      isEditMode = false;
      editingMessage = null;
    });
    context.read<TChatCubit>().setIsMessagePending(false);
  }

  void cancelEdit() {
    setState(() {
      isEditMode = false;
      editingMessage = null;
      messageController.clear();
    });
  }
}
