import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.shellIndex, required this.goBranch});

  final int shellIndex;
  final Function(int index) goBranch;

  static final _icons = [
    Assets.icons.homeS36,
    Assets.icons.chatBubbleS36,
    Assets.icons.calendarS36,
    Assets.icons.mailS36,
    Assets.icons.callS36,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 80,
      child: ClipRRect(
        borderRadius: const .vertical(top: .circular(12)),
        child: ColoredBox(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const .only(right: 12, left: 12, top: 8),
            child: Row(
              crossAxisAlignment: .start,
              mainAxisAlignment: .spaceBetween,
              children: .generate(
                6,
                (index) {
                  final isSelected = index == shellIndex;

                  if (index < 5) {
                    final icon = _icons[index].path;
                    return _BottomBarItem(
                      onTap: () => goBranch(index),
                      child: isSelected ? _ActiveIcon(icon: icon) : _InactiveIcon(icon: icon),
                    );
                  }

                  return _BottomBarItem(
                    onTap: () => goBranch(index),
                    child: isSelected ? _ActiveProfileIcon() : _InactiveProfileIcon(),
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

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: .circular(12.0)),
        clipBehavior: .antiAlias,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

class _ActiveIcon extends StatelessWidget {
  const _ActiveIcon({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Ink(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: .circular(12.0),
        color: textColors.text100.withValues(alpha: 0.05),
      ),
      child: Center(
        child: SvgPicture.asset(
          icon,
          colorFilter: .mode(textColors.text100, .srcIn),
        ),
      ),
    );
  }
}

class _InactiveIcon extends StatelessWidget {
  const _InactiveIcon({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Center(
      child: SvgPicture.asset(
        icon,
        colorFilter: .mode(textColors.text30, .srcIn),
      ),
    );
  }
}

class _ActiveProfileIcon extends StatelessWidget {
  const _ActiveProfileIcon();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Ink(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: .circular(12.0),
        color: textColors.text100.withValues(alpha: 0.05),
      ),
      child: Center(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (_, state) {
            return Center(
              child: UserAvatar(
                size: 36,
                avatarUrl: state.user?.avatarUrl,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InactiveProfileIcon extends StatelessWidget {
  const _InactiveProfileIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (_, state) {
          return Center(
            child: UserAvatar(
              size: 36,
              avatarUrl: state.user?.avatarUrl,
            ),
          );
        },
      ),
    );
  }
}
