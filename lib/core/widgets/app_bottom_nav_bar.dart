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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: .circular(12.0)),
      child: ColoredBox(
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const .only(bottom: 8),
          child: NavigationBar(
            labelPadding: .zero,
            labelBehavior: .alwaysHide,
            selectedIndex: shellIndex,
            onDestinationSelected: goBranch,
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            indicatorShape: RoundedRectangleBorder(borderRadius: .all(.circular(12))),
            destinations: [
              NavigationDestination(
                label: '',
                icon: _NavSvgIcon(icon: Assets.icons.homeS36.path),
                selectedIcon: _NavSvgIcon.selected(icon: Assets.icons.homeS36.path),
              ),
              NavigationDestination(
                label: '',
                icon: _NavSvgIcon(icon: Assets.icons.chatBubbleS36.path),
                selectedIcon: _NavSvgIcon.selected(icon: Assets.icons.chatBubbleS36.path),
              ),
              NavigationDestination(
                label: '',
                icon: _NavSvgIcon(icon: Assets.icons.calendarS36.path),
                selectedIcon: _NavSvgIcon.selected(icon: Assets.icons.calendarS36.path),
              ),
              NavigationDestination(
                label: '',
                icon: _NavSvgIcon(icon: Assets.icons.mailS36.path),
                selectedIcon: _NavSvgIcon.selected(icon: Assets.icons.mailS36.path),
              ),
              // NavigationDestination(
              //   label: '',
              //   icon: _NavIcon(icon: Assets.icons.groupS36.path),
              //   selectedIcon: _NavIcon.selected(icon: Assets.icons.groupS36.path),
              // ),
              // NavigationDestination(
              //   label: '',
              //   icon: _NavIcon(icon: Assets.icons.callS36.keyName),
              //   selectedIcon: _NavIcon.selected(icon: Assets.icons.callS36.path),
              // ),
              NavigationDestination(
                label: '',
                icon: _NavIconDataIcon(),
                selectedIcon: _NavIconDataIcon.selected(),
              ),
              NavigationDestination(
                label: '',
                icon: _NavWidgetIcon(),
                selectedIcon: _NavWidgetIcon.selected(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSvgIcon extends StatelessWidget {
  const _NavSvgIcon({super.key, required this.icon}) : _isSelected = false;

  const _NavSvgIcon.selected({super.key, required this.icon}) : _isSelected = true;

  final bool _isSelected;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AnimatedScale(
        scale: _isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: SvgPicture.asset(

          icon,
          colorFilter: ColorFilter.mode(
            _isSelected ? Colors.white : textColors.text30,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _NavIconDataIcon extends StatelessWidget {
  const _NavIconDataIcon({super.key}) : _isSelected = false;

  const _NavIconDataIcon.selected({super.key}) : _isSelected = true;

  final bool _isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AnimatedScale(
        scale: _isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Icon(Icons.library_books_sharp, size: 28, color: _isSelected ? Colors.white : textColors.text30),
      ),
    );
  }
}

class _NavWidgetIcon extends StatelessWidget {
  const _NavWidgetIcon({super.key}) : _isSelected = false;

  const _NavWidgetIcon.selected({super.key}) : _isSelected = true;

  final bool _isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return Container(
            padding: const EdgeInsets.all(2),
            decoration: _isSelected
                ? const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 2),
                    ),
                  )
                : null,
            child: UserAvatar(
              size: 36,
              avatarUrl: profileState.user?.avatarUrl,
            ),
          );
        },
      ),
    );
  }
}
