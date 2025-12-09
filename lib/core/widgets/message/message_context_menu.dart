import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MessageContextMenu extends StatefulWidget {
  const MessageContextMenu({
    super.key,
    required this.isStarred,
    this.onReply,
    this.onCopy,
    this.onToggleStar,
    required this.onEmojiSelected,
    this.onEdit,
    this.onDelete,
    this.onClose,
    required this.offset,
    required this.isMyMessage,
  });

  final bool isStarred;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onToggleStar;
  final VoidCallback? onDelete;
  final ValueChanged<String> onEmojiSelected;
  final VoidCallback? onClose;
  final Offset offset;
  final bool isMyMessage;

  @override
  State<MessageContextMenu> createState() => _MessageContextMenuState();
}

class _MessageContextMenuState extends State<MessageContextMenu> with SingleTickerProviderStateMixin {
  final isEmoji = ValueNotifier(false);

  final parser = EmojiParser();

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
  }

  void _onReplay() {
    widget.onReply?.call();
    _close();
  }

  void _onEdit() {
    widget.onEdit?.call();
    _close();
  }

  void _onDelete() {
    widget.onDelete?.call();
    _close();
  }

  void _onCopy() {
    widget.onCopy?.call();
    _close();
  }

  void _onToggleStar() {
    widget.onToggleStar?.call();
    _close();
  }

  void _onEmojiSelected(String value) {
    widget.onEmojiSelected(value);
    _close();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = colors.onSurface.withValues(alpha: 0.9);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
            onSecondaryTapDown: (_) => _close,
          ),
        ),
        Positioned(
          left: !widget.isMyMessage ? widget.offset.dx : null,
          right: widget.isMyMessage ? screenWidth - widget.offset.dx : null,
          top: widget.offset.dy,
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              alignment: widget.isMyMessage ? .topRight : .topLeft,
              child: Material(
                elevation: 4,
                borderRadius: .circular(8),
                clipBehavior: .antiAlias,
                child: ValueListenableBuilder(
                  valueListenable: isEmoji,
                  builder: (context, value, _) {
                    final width = value ? 300 : 240;
                    return Container(
                      width: width.toDouble(),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: .circular(8.0),
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: isEmoji,
                        builder: (context, value, _) {
                          if (value) {
                            return EmojiPicker(
                              onEmojiSelected: (category, emoji) {
                                final selected = parser.getEmoji(emoji.emoji);
                                _onEmojiSelected(selected.name);
                              },
                              config: Config(
                                height: 360,
                                emojiViewConfig: const EmojiViewConfig(
                                  emojiSizeMax: 22,
                                  backgroundColor: Colors.transparent,
                                ),
                                categoryViewConfig: CategoryViewConfig(
                                  tabIndicatorAnimDuration: const Duration(milliseconds: 500),
                                  backgroundColor: theme.colorScheme.surface,
                                  iconColorSelected: theme.colorScheme.primary,
                                  iconColor: theme.colorScheme.outline,
                                ),
                                bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                              ),
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ReactionsRow(
                                onEmojiSelected: _onEmojiSelected,
                                onOpenEmojiPicker: () => isEmoji.value = !isEmoji.value,
                              ),
                              const SizedBox(height: 10),
                              _ActionTile(
                                textColor: textColor,
                                icon: Assets.icons.replay,
                                label: context.t.contextMenu.reply,
                                onTap: _onReplay,
                              ),
                              if (widget.onEdit != null)
                                _ActionTile(
                                  textColor: textColor,
                                  icon: Assets.icons.edit,
                                  label: context.t.contextMenu.edit,
                                  onTap: _onEdit,
                                ),
                              _ActionTile(
                                textColor: textColor,
                                icon: Assets.icons.fileCopy,
                                label: context.t.contextMenu.copy,
                                onTap: _onCopy,
                              ),
                              _ActionTile(
                                textColor: textColor,
                                icon: Assets.icons.reSend,
                                label: context.t.contextMenu.forward,
                              ),
                              _ActionTile(
                                textColor: textColor,
                                icon: Assets.icons.bookmark,
                                label: widget.isStarred
                                    ? context.t.contextMenu.unmarkAsImportant
                                    : context.t.contextMenu.markAsImportant,
                                onTap: _onToggleStar,
                              ),
                              if (widget.onDelete != null)
                                _ActionTile(
                                  textColor: textColor,
                                  icon: Assets.icons.delete,
                                  label: context.t.contextMenu.delete,
                                  onTap: _onDelete,
                                ),
                              _ActionTile(
                                textColor: textColor,
                                icon: Assets.icons.checkCircle,
                                label: context.t.contextMenu.select,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.textColor,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final Color textColor;
  final SvgGenImage icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 36.0,
      child: Material(
        child: InkWell(
          borderRadius: .circular(8),
          onTap: onTap,
          child: Padding(
            padding: const .symmetric(horizontal: 12.0),
            child: Row(
              children: [
                icon.svg(width: 20, height: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionsRow extends StatelessWidget {
  const _ReactionsRow({
    required this.onEmojiSelected,
    required this.onOpenEmojiPicker,
  });

  final ValueChanged<String> onEmojiSelected;
  final VoidCallback? onOpenEmojiPicker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 36.0,
      child: Padding(
        padding: const .symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            for (final emoji in AppConstants.popularEmojis)
              Material(
                child: InkWell(
                  borderRadius: .circular(20),
                  onTap: () {
                    onEmojiSelected(emoji.emojiName.replaceAll(':', ''));
                  },
                  child: Padding(
                    padding: const .all(4.0),
                    child: UnicodeEmojiWidget(emojiDisplay: emoji, size: 20),
                  ),
                ),
              ),
            Material(
              child: InkWell(
                borderRadius: .circular(20),
                onTap: onOpenEmojiPicker,
                child: Padding(
                  padding: const .all(4.0),
                  child: Icon(Icons.add, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: .3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
