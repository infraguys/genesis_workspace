import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/app_bar/view/organization_horizonlat_item.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AppMobileDrawer extends StatelessWidget {
  const AppMobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                context.t.organizations.title,
                style: theme.textTheme.bodyLarge,
              ),
              BlocBuilder<OrganizationsCubit, OrganizationsState>(
                builder: (context, state) {
                  final organizations = state.organizations;
                  final selectedId = state.selectedOrganizationId;
                  return ListView.separated(
                    itemCount: organizations.length,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (_, _) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final organization = organizations[index];
                      return OrganizationHorizonlatItem(
                        name: organization.name,
                        unreadCount: organization.unreadMessages.length,
                        imagePath: organization.imageUrl,
                        isSelected: organization.id == selectedId,
                        onTap: () async {
                          final organizationsCubit = context.read<OrganizationsCubit>();

                          await Future.wait([
                            organizationsCubit.selectOrganization(organization),
                          ]);
                        },
                        onDelete: () async {
                          await context.read<OrganizationsCubit>().removeOrganization(
                            organization.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
