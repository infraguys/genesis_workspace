import 'dart:async';

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
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class ScaffoldDesktopAppBar extends StatelessWidget {
  final Function(int index) onSelectBranch;
  final int selectedIndex;
  const ScaffoldDesktopAppBar({
    super.key,
    required this.onSelectBranch,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = Theme.of(context).extension<TextColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 12,
          decoration: BoxDecoration(color: theme.colorScheme.surface),
        ),
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 8,
              decoration: BoxDecoration(color: theme.colorScheme.surface),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15).copyWith(top: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 16,
                            children: [
                              BlocBuilder<OrganizationsCubit, OrganizationsState>(
                                builder: (context, state) {
                                  final organizations = state.organizations;
                                  final selectedId = state.selectedOrganizationId;
                                  return SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                      itemCount: organizations.length,
                                      scrollDirection: Axis.horizontal,
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      separatorBuilder: (_, _) {
                                        return SizedBox(width: 16);
                                      },
                                      itemBuilder: (BuildContext context, int index) {
                                        final organization = organizations[index];
                                        return OrganizationItem(
                                          unreadCount: organization.unreadCount,
                                          imagePath: organization.imageUrl,
                                          isSelected: organization.id == selectedId,
                                          onTap: () {
                                            context.read<OrganizationsCubit>().selectOrganization(
                                              organization,
                                            );
                                            unawaited(context.read<ProfileCubit>().getOwnUser());
                                          },
                                          onDelete: () async {
                                            context.pop();
                                            await context
                                                .read<OrganizationsCubit>()
                                                .removeOrganization(organization.id);
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
                                          builder: (BuildContext dialogContext) =>
                                              const AddOrganizationDialog(),
                                        );
                                        if (url != null && context.mounted) {
                                          await context.read<OrganizationsCubit>().addOrganization(
                                            url,
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      mouseCursor: SystemMouseCursors.click,
                                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                                        states,
                                      ) {
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
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12, bottom: 0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      shrinkWrap: true,
                      separatorBuilder: (_, _) => SizedBox(width: 2),
                      itemBuilder: (BuildContext context, int index) {
                        return BranchItem(
                          isSelected: index == selectedIndex,
                          onPressed: () => onSelectBranch(index),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15).copyWith(top: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 24,
                      children: [
                        Expanded(
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 12,
                          children: [
                            UserAvatar(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Исакова Дарья',
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
                            IconButton(onPressed: () {}, icon: Assets.icons.arrowDown.svg()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }
}
