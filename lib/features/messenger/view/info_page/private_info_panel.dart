import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
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
    final cardColors = Theme.of(context).extension<CardColors>()!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: .circular(12.0),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 20.0,
        children: [
          Padding(
            padding: const .only(left: 20.0, right: 20.0, top: 20.0),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 12,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      context.t.information,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    IconButton(onPressed: onClose, icon: Assets.icons.close.svg()),
                  ],
                ),
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
                      return Column(
                        spacing: 8.0,
                        children: [
                          _InfoWidget(
                            iconData: Icons.call,
                            title: context.t.phone,
                            value: '+5456546546',
                          ),
                          _InfoWidget(
                            iconData: Icons.person,
                            title: context.t.username,
                            value: state.userEntity?.fullName ?? '',
                          ),
                          _InfoWidget(
                            iconData: Icons.account_circle,
                            title: context.t.role,
                            value: state.userEntity!.role.humanReadable(context),
                          ),
                          _InfoWidget(
                            iconData: Icons.date_range,
                            title: context.t.birthday,
                            value: '25 июля 1984',
                          ),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 8.0),
            child: Row(
              spacing: 8.0,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: .circular(8.0),
                    clipBehavior: .hardEdge,
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
                      color: cardColors.base,
                      child: InkWell(
                        onTap: () {},
                        child: SizedBox(
                          height: 56.0,
                          child: Center(child: Assets.icons.call.svg(width: 40)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: .circular(8.0),
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(8.0),
                      ),
                      color: cardColors.base,
                      child: InkWell(
                        onTap: () {},
                        child: SizedBox(
                          height: 56.0,
                          child: Center(child: Assets.icons.search.svg(width: 40)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  const _InfoWidget({
    super.key,
    required this.title,
    required this.value,
    required this.iconData,
  });

  final String title;
  final String value;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final textColors = Theme.of(context).extension<TextColors>()!;

    return Row(
      mainAxisAlignment: .start,
      spacing: 18.0,
      children: [
        Icon(iconData, color: textColors.text30),
        Column(
          crossAxisAlignment: .start,
          spacing: 4.0,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                color: textColors.text30,
                fontWeight: .w400,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.0,
                color: textColors.text100,
                fontWeight: .w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
