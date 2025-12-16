import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ProfilePersonalInfoPage extends StatelessWidget {
  const ProfilePersonalInfoPage({super.key, required this.onBack, this.onClose});

  final VoidCallback onBack;
  final VoidCallback? onClose;

  Future<void> shareProfile(
    BuildContext context, {
    required int userId,
  }) async {
    final theme = Theme.of(context);
    final url = "${AppConstants.baseUrl}/#user/$userId";
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Ссылка на профиль скопирована в буфер обмена",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    final cardColors = theme.extension<CardColors>()!;
    final isMobile = currentSize(context) <= .tablet;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              onPressed: onBack,
              icon: Assets.icons.arrowLeft.svg(),
            ),
            backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
            centerTitle: isMobile,
            title: Text(
              "Личная информация",
              style: theme.textTheme.labelLarge,
            ),
            actions: [
              if (!isMobile)
                IconButton(
                  onPressed: onClose,
                  icon: Assets.icons.close.svg(),
                ),
              if (isMobile) ...[
                IconButton(
                  onPressed: state.user != null
                      ? () async {
                          await shareProfile(context, userId: user!.userId);
                        }
                      : null,
                  icon: Assets.icons.link.svg(width: 24),
                ),
              ],
            ],
          ),
          body: Builder(
            builder: (context) {
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      UserAvatar(avatarUrl: user.avatarUrl, size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.t.online,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!isMobile) ...[
                    ListTile(
                      leading: Assets.icons.link.svg(),
                      contentPadding: .zero,
                      onTap: () async {
                        await shareProfile(context, userId: user.userId);
                      },
                      title: Text(
                        "Поделиться профилем",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Divider(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ],

                  // _InfoTile(
                  //   label: "Статус",
                  //   value: user.email,
                  //   icon: Assets.icons.work.svg(),
                  // ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: context.t.email,
                    value: user.email,
                    icon: SizedBox(
                      width: 32,
                      child: Assets.icons.mail.svg(width: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _InfoTile(
                    label: "ID пользователя",
                    value: user.userId.toString(),
                    icon: Assets.icons.alternateEmail.svg(),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _InfoTile(
                    label: "Часовой пояс",
                    value: user.timezone,
                    icon: Assets.icons.schedule.svg(),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _InfoTile(
                    label: "Команда > Должность",
                    value: user.jobTitle,
                    icon: Assets.icons.businessCenter.svg(),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _InfoTile(
                    label: "Руководитель",
                    value: user.bossName,
                    icon: Assets.icons.handshake.svg(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;

    return Row(
      crossAxisAlignment: .center,
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColors.text30,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
