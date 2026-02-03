import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class MentionSuggestions extends StatefulWidget {
  final FocusNode inputFocusNode;
  final FocusNode mentionFocusNode;
  final bool showPopup;
  final List<UserEntity> suggestedMentions;
  final bool isSuggestionsPending;
  final List<UserEntity> filteredSuggestedMentions;
  final Function(String fullName) onSelectMention;

  const MentionSuggestions({
    super.key,
    required this.inputFocusNode,
    required this.showPopup,
    required this.suggestedMentions,
    required this.isSuggestionsPending,
    required this.filteredSuggestedMentions,
    required this.onSelectMention,
    required this.mentionFocusNode,
  });

  @override
  State<MentionSuggestions> createState() => _MentionSuggestionsState();
}

class _MentionSuggestionsState extends State<MentionSuggestions> {
  final ScrollController _scrollController = ScrollController();

  int focusedMentionIndex = 0;

  // Public helpers to control selection from parent via GlobalKey
  void moveNext() {
    if (widget.filteredSuggestedMentions.isEmpty) return;
    final int lastIndex = widget.filteredSuggestedMentions.length - 1;
    setState(() {
      focusedMentionIndex = (focusedMentionIndex >= lastIndex) ? lastIndex : focusedMentionIndex + 1;
    });
    _scrollToFocused();
  }

  void movePrevious() {
    if (widget.filteredSuggestedMentions.isEmpty) return;
    setState(() {
      focusedMentionIndex = (focusedMentionIndex <= 0) ? 0 : focusedMentionIndex - 1;
    });
    _scrollToFocused();
  }

  void selectFocused() {
    selectMention(focusedMentionIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MentionSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.showPopup && widget.showPopup) {
      // Reset selection when the popup is shown, but do not steal focus
      focusedMentionIndex = 0;
    }

    if (oldWidget.filteredSuggestedMentions.length != widget.filteredSuggestedMentions.length) {
      if (widget.filteredSuggestedMentions.isEmpty) {
        focusedMentionIndex = 0;
      } else {
        focusedMentionIndex = focusedMentionIndex.clamp(
          0,
          widget.filteredSuggestedMentions.length - 1,
        );
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.showPopup || widget.filteredSuggestedMentions.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final int lastIndex = widget.filteredSuggestedMentions.length - 1;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (focusedMentionIndex != lastIndex) {
        setState(() {
          focusedMentionIndex = (focusedMentionIndex >= lastIndex) ? 0 : focusedMentionIndex + 1;
        });
        _scrollToFocused();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (focusedMentionIndex != 0) {
        setState(() {
          focusedMentionIndex = (focusedMentionIndex <= 0) ? lastIndex : focusedMentionIndex - 1;
        });
        _scrollToFocused();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      selectMention(focusedMentionIndex);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _scrollToFocused() {
    if (!_scrollController.hasClients) return;
    final double itemHeight = 44 + 4;
    final double targetOffset = (focusedMentionIndex * itemHeight).clamp(0, double.infinity);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  void selectMention(int index) {
    if (index < 0 || index >= widget.filteredSuggestedMentions.length) return;
    final UserEntity user = widget.filteredSuggestedMentions[index];
    widget.onSelectMention(user.fullName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      opacity: widget.showPopup ? 1 : 0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !widget.showPopup,
        child: Focus(
          focusNode: widget.mentionFocusNode,
          canRequestFocus: false,
          onKeyEvent: _onKey,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: SizedBox(
              width: 300,
              height: 200,
              child: Builder(
                builder: (context) {
                  if (widget.suggestedMentions.isEmpty && widget.isSuggestionsPending) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.filteredSuggestedMentions.isEmpty) {
                    return Center(
                      child: Text(
                        context.t.nothingFound,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (widget.isSuggestionsPending) const LinearProgressIndicator(),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          physics: const ClampingScrollPhysics(),
                          itemCount: widget.filteredSuggestedMentions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final UserEntity user = widget.filteredSuggestedMentions[index];
                            final bool isFocused = index == focusedMentionIndex;

                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: () => selectMention(index),
                                onHover: (hover) {
                                  if (hover) setState(() => focusedMentionIndex = index);
                                },
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isFocused
                                        ? theme.colorScheme.primary.withValues(alpha: 0.10)
                                        : Colors.transparent,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  alignment: Alignment.centerLeft,
                                  child: ListTile(
                                    leading: UserAvatar(avatarUrl: user.avatarUrl, size: 24),
                                    title: Text(
                                      user.fullName,
                                      style: theme.textTheme.bodyMedium!.copyWith(
                                        color: isFocused ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
