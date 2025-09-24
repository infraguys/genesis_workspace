import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/chats/common/widgets/user_tile.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class AllChatsDms extends StatelessWidget {
  const AllChatsDms({super.key});

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
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 500),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: directMessagesState.recentDmsUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  final DmUserEntity user = directMessagesState.recentDmsUsers[index].toDmUser();
                  return UserTile(
                    user: user,
                    onTap: () {
                      context.read<AllChatsCubit>().selectDmChat(user);
                    },
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
