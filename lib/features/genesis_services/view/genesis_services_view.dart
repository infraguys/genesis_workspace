import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/features/genesis_services/bloc/genesis_services_cubit.dart';
import 'package:genesis_workspace/features/genesis_services/view/service_item.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GenesisServicesView extends StatelessWidget {
  const GenesisServicesView({super.key});

  static const double spacing = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextColors textColors = theme.extension<TextColors>()!;
    final genesisServicesTexts = context.t.genesisServices;

    final isTabletOrSmaller = currentSize(context) <= ScreenSize.tablet;
    final minCardWidth = isTabletOrSmaller ? 170 : 458;
    final double expectedCardHeight = isTabletOrSmaller ? 224 : 210;
    final double childAspectRatio = minCardWidth / expectedCardHeight;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                genesisServicesTexts.title,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 32, fontWeight: .w500),
              ),
              Text(
                genesisServicesTexts.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColors.text30,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<GenesisServicesCubit, GenesisServicesState>(
            builder: (context, state) {
              final services = state is GenesisServicesLoaded
                  ? state.services
                  : List.generate(15, (int index) => GenesisServiceEntity.fake());
              if (state is GenesisServicesError) {
                return Center(
                  child: Column(
                    spacing: 16,
                    children: [
                      Text(
                        context.t.error,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: .w500,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await context.read<GenesisServicesCubit>().loadServices();
                        },
                        child: Text(genesisServicesTexts.tryAgain, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  await context.read<GenesisServicesCubit>().loadServices();
                },
                child: Skeletonizer(
                  enabled: state is! GenesisServicesLoaded,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;

                      final int columnsCount = (maxWidth / (minCardWidth + spacing)).floor().clamp(2, 12);

                      return GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: spacing),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnsCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return ServiceItem(service: service);
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
