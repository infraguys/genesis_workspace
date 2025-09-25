import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/all_chats/view/select_folders_dialog.dart';
import 'package:genesis_workspace/features/chats/common/widgets/user_tile.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class AllChatsDms extends StatelessWidget {
  final Set<int>? filteredDms;
  const AllChatsDms({super.key, required this.filteredDms});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            context.t.navBar.directMessages,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        BlocConsumer<DirectMessagesCubit, DirectMessagesState>(
          listenWhen: (previous, next) => previous.selectedUserId != next.selectedUserId,
          listener: (context, state) {
            if (currentSize(context) > ScreenSize.lTablet) {
              final String targetPath = (state.selectedUserId == null)
                  ? Routes.directMessages
                  : '${Routes.directMessages}/${state.selectedUserId}';

              final String currentLocation = GoRouterState.of(context).uri.toString();

              if (currentLocation != targetPath) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  updateBrowserUrlPath(targetPath);
                });
              }
            }
          },
          builder: (context, directMessagesState) {
            final users = filteredDms == null
                ? directMessagesState.recentDmsUsers
                : directMessagesState.recentDmsUsers
                      .where((u) => filteredDms!.contains(u.userId))
                      .toList(growable: false);
            if (users.isEmpty) {
              return const SizedBox.shrink();
            }
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 500),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  final DmUserEntity user = users[index].toDmUser();
                  final popupKey = GlobalKey<CustomPopupState>();
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
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                        boxShadow: kElevationToShadow[3],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: const Icon(Icons.folder_open),
                          title: Text(context.t.folders.addToFolder),
                          onTap: () async {
                            // popupKey.currentState?.hide();
                            context.pop();
                            await context.read<AllChatsCubit>().loadFolders();
                            await showDialog(
                              context: context,
                              builder: (_) => SelectFoldersDialog(
                                loadSelectedFolderIds: () =>
                                    context.read<AllChatsCubit>().getFolderIdsForDm(user.userId),
                                onSave: (ids) =>
                                    context.read<AllChatsCubit>().setFoldersForDm(user.userId, ids),
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
                        user: user,
                        onTap: () {
                          context.read<AllChatsCubit>().selectDmChat(user);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
