import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/desktop_app_bar/view/branch_item.dart';
import 'package:genesis_workspace/features/desktop_app_bar/view/organization_item.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/organizations/view/add_organization_dialog.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class ScaffoldDesktopAppBar extends StatefulWidget {
  final Function(int index) onSelectBranch;
  final int selectedIndex;

  const ScaffoldDesktopAppBar({
    super.key,
    required this.onSelectBranch,
    required this.selectedIndex,
  });

  @override
  State<ScaffoldDesktopAppBar> createState() => _ScaffoldDesktopAppBarState();
}

class _ScaffoldDesktopAppBarState extends State<ScaffoldDesktopAppBar> {
  final mainTitleNotifier = ValueNotifier<String>('');

  @override
  void didChangeDependencies() {
    mainTitleNotifier.value = context.t.messenger;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textColors = Theme.of(context).extension<TextColors>()!;
    return Column(
      children: [
        Container(
          height: 40.0,
          width: double.infinity,
          color: theme.colorScheme.surface,
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: mainTitleNotifier,
              builder: (_, value, _) => Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        Container(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
            child: SizedBox(
              height: 64.0,
              child: Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: Row(
                      spacing: 16.0,
                      children: [
                        BlocBuilder<OrganizationsCubit, OrganizationsState>(
                          builder: (_, state) {
                            final organizations = state.organizations;
                            final selectedId = state.selectedOrganizationId;
                            return SizedBox(
                              height: 40,
                              child: ListView.separated(
                                itemCount: organizations.length,
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (_, _) => SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final organization = organizations[index];
                                  return OrganizationItem(
                                    unreadCount: organization.unreadMessages.length,
                                    imagePath: organization.imageUrl,
                                    isSelected: organization.id == selectedId,
                                    onTap: () async {
                                      final profileCubit = context.read<ProfileCubit>();
                                      final organizationsCubit = context.read<OrganizationsCubit>();

                                      await Future.wait([
                                        organizationsCubit.selectOrganization(organization),
                                        profileCubit.getOwnUser(),
                                      ]);
                                    },
                                    onDelete: () async {
                                      context.pop();
                                      await context.read<OrganizationsCubit>().removeOrganization(
                                        organization.id,
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        if (!kIsWeb)
                          Material(
                            color: Colors.transparent,
                            child: Ink(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final url = await showDialog<String>(
                                    context: context,
                                    builder: (BuildContext dialogContext) => const AddOrganizationDialog(),
                                  );
                                  if (url != null && context.mounted) {
                                    await context.read<OrganizationsCubit>().addOrganization(url);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                mouseCursor: SystemMouseCursors.click,
                                overlayColor: WidgetStateProperty.resolveWith((states) {
                                  final Color primary = Theme.of(context).colorScheme.primary;
                                  if (states.contains(WidgetState.pressed)) {
                                    return primary.withValues(alpha: 0.16);
                                  }
                                  if (states.contains(WidgetState.hovered)) {
                                    return primary.withValues(alpha: 0.08);
                                  }
                                  return null;
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(child: Assets.icons.add.svg()),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: branchModels.length,
                      shrinkWrap: true,
                      separatorBuilder: (_, _) => SizedBox(width: 2),
                      itemBuilder: (BuildContext context, int index) {
                        final model = branchModels[index];
                        return BranchItem(
                          icon: model.icon,
                          isSelected: index == widget.selectedIndex,
                          onPressed: () {
                            mainTitleNotifier.value = model.title(context);
                            widget.onSelectBranch(index);
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Row(
                      spacing: 16.0,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: context.t.general.find,
                              suffixIcon: Align(
                                widthFactor: 1.0,
                                heightFactor: 1.0,
                                child: Assets.icons.search.svg(width: 20, height: 20),
                              ),
                            ),
                          ),
                        ),
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            return Row(
                              spacing: 12.0,
                              children: [
                                UserAvatar(avatarUrl: state.user?.avatarUrl ?? ''),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.user?.fullName ?? '',
                                      style: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      'Администратор',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: textColors.text30,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),

                                IconButton(
                                  onPressed: () async {
                                    await context.read<RealTimeCubit>().ensureConnection();
                                  },
                                  icon: Assets.icons.arrowDown.svg(),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final branchModels = [
  (icon: Assets.icons.notif.svg(), title: (BuildContext context) => context.t.notifications),
  (icon: Assets.icons.chatBubble.svg(), title: (BuildContext context) => context.t.chats),
  (icon: Assets.icons.calendarMonth.svg(), title: (BuildContext context) => context.t.calendar),
  (icon: Assets.icons.mail.svg(), title: (BuildContext context) => context.t.email),
  (icon: Assets.icons.group.svg(), title: (BuildContext context) => context.t.groups),
  (icon: Assets.icons.call.svg(), title: (BuildContext context) => context.t.calls),
];

//TODO(Koretsky): В будущем попробовать перевести все на CustomMultiChildLayout
// final class AppbarMultiChildLayoutDelegate extends MultiChildLayoutDelegate {
//   static const String leftSection = 'leftSection';
//   static const String centerSection = 'centerSection';
//   static const String searchSection = 'searchSection';
//   static const String rightSection = 'rightSection';
//
//   @override
//   void performLayout(Size size) {
//     final centerX = size.width / 2;
//
//     final leftSize = layoutChild(leftSection, BoxConstraints.loose(size));
//     positionChild(leftSection, Offset(16, size.height - leftSize.height) / 2);
//
//     final centerSectionSize = layoutChild(centerSection, BoxConstraints.loose(size));
//     // final halfCenterSectionWidth = centerSectionSize.width / 2;
//
//     final centerSectionStartX = (size.width - centerSectionSize.width) / 2;
//     final centerSectionEndX = centerSectionStartX + centerSectionSize.width;
//     positionChild(centerSection, Offset(centerSectionStartX, 0));
//
//     final searchSize = layoutChild(searchSection, BoxConstraints.loose(Size(250, 40)));
//
//     double searchStartX = centerSectionEndX + 20;
//     // if (centerSectionEndX + 20 + searchSize.width < size.width) {
//     //   searchStartX = centerSectionEndX + 20;
//     // }
//     positionChild(searchSection, Offset(searchStartX, (size.height - searchSize.height) / 2));
//
//     final rightSize = layoutChild(rightSection, BoxConstraints.loose(size));
//     positionChild(
//       rightSection,
//       Offset(size.width - rightSize.width, (size.height - rightSize.height) / 2),
//     );
//   }
//
//   @override
//   bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
// }
