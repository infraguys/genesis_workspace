import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/app_progress_indicator.dart';
import 'package:genesis_workspace/core/widgets/profile_info_tile.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class PrivateInfoPanel extends StatelessWidget {
  const PrivateInfoPanel({
    super.key, // ignore: unused_element_parameter
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    final iconColors = Theme.of(context).extension<IconColors>()!;
    final isMobile = currentSize(context) <= .tablet;

    return Scaffold(
      backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          context.t.information,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: onClose,
            icon: Assets.icons.close.svg(
              colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: .circular(12.0),
          color: theme.colorScheme.surface,
        ),
        child: Padding(
          padding: const .only(left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 12,
            children: [
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.userEntity != null) {
                    final lastSeen = DateTime.fromMillisecondsSinceEpoch(
                      state.userEntity!.presenceTimestamp * 1000,
                    );

                    return Column(
                      children: [
                        Row(
                          spacing: 16.0,
                          children: [
                            UserAvatar(
                              size: 64,
                              avatarUrl: state.userEntity!.avatarUrl,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    state.userEntity!.fullName,
                                    style: TextStyle(fontWeight: .w500, fontSize: 20),
                                  ),
                                  Text(
                                    isJustNow(lastSeen)
                                        ? context.t.wasOnlineJustNow
                                        : context.t.wasOnline(time: timeAgoText(context, lastSeen)),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14.0, color: textColors.text30, fontWeight: .w400),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.userEntity != null) {
                    final user = state.userEntity!;
                    return Column(
                      spacing: 12.0,
                      children: [
                        ProfileInfoTile(
                          label: context.t.profilePersonalInfo.userId,
                          value: user.userId.toString(),
                          icon: Assets.icons.alternateEmail.svg(
                            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                          ),
                        ),
                        ProfileInfoTile(
                          label: context.t.email,
                          value: user.email,
                          icon: SizedBox(
                            width: 32,
                            child: Assets.icons.mail.svg(
                              width: 24,
                              colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                            ),
                          ),
                        ),
                        ProfileInfoTile(
                          label: context.t.profilePersonalInfo.timezone,
                          value: user.timezone,
                          icon: Assets.icons.schedule.svg(
                            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                          ),
                        ),
                        ProfileInfoTile(
                          label: context.t.profilePersonalInfo.teamAndPosition,
                          value: user.jobTitle,
                          icon: Assets.icons.businessCenter.svg(
                            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                          ),
                        ),
                        ProfileInfoTile(
                          label: context.t.profilePersonalInfo.manager,
                          value: user.bossName,
                          icon: Assets.icons.handshake.svg(
                            colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                          ),
                        ),
                      ],
                    );
                  }
                  return AppProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
