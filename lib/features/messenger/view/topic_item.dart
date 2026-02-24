import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/animated_overlay.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/unread_badge.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/mute/mute_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/message_preview.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TopicItem extends StatefulWidget {
  final ChatEntity chat;
  final TopicEntity topic;

  TopicItem({super.key, required this.chat, required this.topic});

  @override
  State<TopicItem> createState() => _TopicItemState();
}

class _TopicItemState extends State<TopicItem> {
  static const double _menuPadding = 8.0;
  static const double _menuItemHeight = 36.0;
  static const double _menuRowHorizontalPadding = 12.0;
  static const double _menuIconSize = 20.0;
  static const double _menuIconTextSpacing = 12.0;

  static OverlayEntry? _menuEntry;

  double _calculateMenuWidth(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final textStyle = textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    final textPainter = TextPainter(
      text: TextSpan(text: context.t.readAllMessages, style: textStyle),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout();

    final contentWidth = (_menuRowHorizontalPadding * 2) + _menuIconSize + _menuIconTextSpacing + textPainter.width;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth - (_menuPadding * 2);

    return contentWidth.clamp(_menuIconSize + (_menuRowHorizontalPadding * 2), maxWidth);
  }

  void _closeOverlay() {
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _openContextMenu(Offset globalPosition) {
    _closeOverlay();

    if (!mounted) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }

    final localInOverlay = overlayBox.globalToLocal(globalPosition);
    final screenSize = MediaQuery.sizeOf(context);
    final menuWidth = _calculateMenuWidth(context);

    final estimatedHeight = _menuItemHeight + (_menuPadding * 2);
    final openDown = (screenSize.height - localInOverlay.dy - _menuPadding) > estimatedHeight;
    final left = localInOverlay.dx.clamp(_menuPadding, screenSize.width - menuWidth - _menuPadding);

    _menuEntry = OverlayEntry(
      builder: (context) {
        return AnimatedOverlay(
          left: left,
          top: openDown ? localInOverlay.dy : null,
          bottom: openDown ? null : (screenSize.height - localInOverlay.dy),
          alignment: openDown ? Alignment.topLeft : Alignment.bottomLeft,
          closeOverlay: _closeOverlay,
          child: _TopicContextMenu(
            topic: widget.topic,
            width: menuWidth,
            onReadAll: () async {
              _closeOverlay();
              await context.read<MessengerCubit>().readAllMessages(
                widget.chat.id,
                topicName: widget.topic.name,
              );
            },
            onMuteTopic: () async {
              try {
                await context.read<MuteCubit>().muteTopic(
                  streamId: widget.chat.streamId!,
                  topic: widget.topic.name,
                );
              } on DioException catch (e) {
                showErrorSnackBar(context, exception: e);
              } finally {
                _closeOverlay();
              }
            },
            onUnmuteTopic: () async {
              try {
                await context.read<MuteCubit>().unmuteTopic(
                  streamId: widget.chat.streamId!,
                  topic: widget.topic.name,
                );
              } on DioException catch (e) {
                if (context.mounted) {
                  showErrorSnackBar(context, exception: e);
                }
              } finally {
                _closeOverlay();
              }
            },
          ),
        );
      },
    );

    overlay.insert(_menuEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColors = theme.extension<CardColors>()!;
    final textColors = theme.extension<TextColors>()!;
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
          _openContextMenu(event.position);
        }
      },
      child: GestureDetector(
        onLongPressStart: (details) {
          if (platformInfo.isMobile) {
            _openContextMenu(details.globalPosition);
          }
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            context.read<MessengerCubit>().selectChat(
              widget.chat,
              selectedTopic: widget.topic.name,
            );
          },
          child: BlocBuilder<MessengerCubit, MessengerState>(
            builder: (context, state) {
              final isSelected = widget.topic.name == state.selectedTopic;
              return Container(
                height: 76,
                padding: EdgeInsetsGeometry.only(left: 38, right: 8, bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? cardColors.active : cardColors.base,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 3,
                            height: 47,
                            decoration: BoxDecoration(
                              color: widget.chat.backgroundColor ?? AppColors.primary,
                              borderRadius: BorderRadiusGeometry.circular(4),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 4,
                                  children: [
                                    Tooltip(
                                      message: widget.topic.name,
                                      child: Text(
                                        "# ${widget.topic.name}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontSize: 14,
                                          color: textColors.text100,
                                        ),
                                      ),
                                    ),
                                    if (widget.topic.visibilityPolicy == .muted)
                                      Icon(
                                        Icons.headset_off,
                                        size: 14,
                                        color: AppColors.noticeDisabled,
                                      ),
                                  ],
                                ),
                                Text(
                                  widget.topic.lastMessageSenderName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                MessagePreview(
                                  messagePreview: widget.topic.lastMessagePreview,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Skeleton.ignore(
                      child: SizedBox(
                        height: 21,
                        child: UnreadBadge(
                          count: widget.topic.unreadMessages.length,
                          isMuted: widget.chat.isMuted || widget.topic.isMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopicContextMenu extends StatelessWidget {
  const _TopicContextMenu({
    required this.topic,
    required this.width,
    required this.onReadAll,
    required this.onMuteTopic,
    required this.onUnmuteTopic,
  });

  final TopicEntity topic;
  final double width;
  final VoidCallback onReadAll;
  final VoidCallback onMuteTopic;
  final VoidCallback onUnmuteTopic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const textColor = Colors.white;
    const iconColor = ColorFilter.mode(Colors.white, BlendMode.srcIn);

    final isMuted = topic.visibilityPolicy == .muted;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _TopicContextMenuAction(
            textColor: textColor,
            icon: Assets.icons.readReceipt,
            iconColor: iconColor,
            label: context.t.readAllMessages,
            onTap: onReadAll,
          ),
          _TopicContextMenuAction(
            textColor: textColor,
            icon: Assets.icons.notif,
            iconColor: iconColor,
            label: isMuted ? context.t.topicItem.unmute : context.t.topicItem.mute,
            onTap: isMuted ? onUnmuteTopic : onMuteTopic,
          ),
        ],
      ),
    );
  }
}

class _TopicContextMenuAction extends StatelessWidget {
  const _TopicContextMenuAction({
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final Color textColor;
  final SvgGenImage icon;
  final ColorFilter iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    const iconSize = 20.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36.0),
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Row(
              spacing: 12.0,
              children: [
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: icon.svg(
                    width: iconSize,
                    height: iconSize,
                    colorFilter: iconColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor,
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
