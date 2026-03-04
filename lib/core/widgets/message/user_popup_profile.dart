import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/app_shell_controller.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserPopupProfile extends StatefulWidget {
  final int userId;
  const UserPopupProfile({super.key, required this.userId});

  @override
  State<UserPopupProfile> createState() => _UserPopupProfileState();
}

class _UserPopupProfileState extends State<UserPopupProfile> with OpenChatMixin {
  late final Future _future;
  final AppShellController appShellController = getIt<AppShellController>();
  final GetUserByIdUseCase _getUserByIdUseCase = getIt<GetUserByIdUseCase>();
  DmUserEntity _user = UserEntity.fake().toDmUser();

  Future<void> getUserById(int userId) async {
    final UserEntity user = await _getUserByIdUseCase.call(userId);
    setState(() {
      _user = user.toDmUser();
    });
  }

  @override
  void initState() {
    _future = getUserById(widget.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, snapshot) {
        return Skeletonizer(
          enabled: snapshot.connectionState == .waiting,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(avatarUrl: _user.avatarUrl),
              SelectableText(
                _user.fullName,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SelectableText(_user.email, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      context.pop();
                      if (currentSize(context) > ScreenSize.lTablet) {
                        const SetEquality<int> _setEquals = SetEquality<int>();
                        appShellController.goToBranch(AppShellBranchIndex.messenger);
                        final messengerState = context.read<MessengerCubit>().state;
                        final memberIds = {messengerState.selfUser?.userId ?? -1, widget.userId};
                        final chat = messengerState.chats.firstWhereOrNull(
                          (chat) => _setEquals.equals(chat.dmIds?.toSet(), memberIds),
                        );
                        openChat(context, membersIds: memberIds, chatId: chat?.id ?? -1);
                      } else {
                        context.pushNamed(
                          Routes.chat,
                          pathParameters: {'userId': _user.userId.toString()},
                        );
                      }
                    },
                    child: Ink(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(6),
                        color: theme.colorScheme.surface,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.t.openChat,
                            style: theme.textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
