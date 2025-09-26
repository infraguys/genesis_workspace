import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/chats/common/widgets/user_tile.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class AllChatsDms extends StatefulWidget {
  final Set<int>? filteredDms;
  const AllChatsDms({super.key, required this.filteredDms});

  @override
  State<AllChatsDms> createState() => _AllChatsDmsState();
}

class _AllChatsDmsState extends State<AllChatsDms> with TickerProviderStateMixin {
  late final AnimationController expandController;
  late final Animation<double> expandAnimation;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 180),
    );
    expandAnimation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    expandController.value = 1.0;
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  void toggleExpanded() {
    setState(() => isExpanded = !isExpanded);
    if (isExpanded) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
      builder: (context, directMessagesState) {
        final List<DmUserEntity> users = (widget.filteredDms == null)
            ? directMessagesState.filteredRecentDmsUsers
            : directMessagesState.filteredRecentDmsUsers
                  .where((user) => widget.filteredDms!.contains(user.userId))
                  .toList();

        if (users.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t.navBar.directMessages,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    splashRadius: 22,
                    onPressed: toggleExpanded,
                    icon: AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0.0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ],
              ),
            ),
            ClipRect(
              child: SizeTransition(
                sizeFactor: expandAnimation,
                axisAlignment: -1.0,
                child: FadeTransition(
                  opacity: expandAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DmUserEntity user = users[index];
                        final GlobalKey<CustomPopupState> popupKey = GlobalKey<CustomPopupState>();

                        return CustomPopup(
                          key: popupKey,
                          position: PopupPosition.auto,
                          contentPadding: EdgeInsets.zero,
                          isLongPress: true,
                          content: Container(
                            width: 240,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.5),
                              ),
                              boxShadow: kElevationToShadow[3],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: const Icon(Icons.folder_open),
                                title: Text(context.t.folders.addToFolder),
                                onTap: () async {
                                  context.pop();
                                  await context.read<AllChatsCubit>().loadFolders();
                                  await showDialog(
                                    context: context,
                                    builder: (_) => SelectFoldersDialog(
                                      loadSelectedFolderIds: () => context
                                          .read<AllChatsCubit>()
                                          .getFolderIdsForDm(user.userId),
                                      onSave: (selectedFolderIds) => context
                                          .read<AllChatsCubit>()
                                          .setFoldersForDm(user.userId, selectedFolderIds),
                                      folders: context.read<AllChatsCubit>().state.folders,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onSecondaryTap: () => popupKey.currentState?.show(),
                            child: UserTile(
                              key: ValueKey(user.userId),
                              user: user,
                              onTap: () {
                                context.read<AllChatsCubit>().selectDmChat(user);
                              },
                            ),
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
      },
    );
  }
}
