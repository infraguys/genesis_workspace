import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceItem extends StatelessWidget {
  final GenesisServiceEntity service;
  const ServiceItem({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextColors textColors = theme.extension<TextColors>()!;
    final CardColors cardColors = theme.extension<CardColors>()!;
    return Container(
      padding: .all(12),
      decoration: BoxDecoration(
        borderRadius: .circular(8),
        color: cardColors.onBackgroundCard,
      ),
      child: Column(
        spacing: 20,
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              ClipRRect(
                borderRadius: .circular(8),
                child: SvgPicture.network(
                  service.icon,
                  width: 64,
                  height: 64,
                  placeholderBuilder: (BuildContext context) {
                    return _serviceIconFallback(theme);
                  },
                  errorBuilder: (context, error, stackTrace) => _serviceIconFallback(theme),
                ),
              ),
              // TapEffectIcon(
              //   child: service.isFavorite ? Assets.icons.starFilled.svg() : Assets.icons.star.svg(),
              // ),
            ],
          ),
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                service.name,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                service.description,
                maxLines: 4,
                overflow: .ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColors.text30,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () {
                launchUrl(
                  Uri.parse(service.serviceUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: Assets.icons.openInNew.svg(
                height: 32,
              ),
              iconAlignment: .end,
              label: Skeleton.ignore(
                child: Text(
                  context.t.open,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColors.text100,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceIconFallback(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8),
        color: theme.colorScheme.surface,
      ),
      width: 64,
      height: 64,
      child: const Icon(
        Icons.interests,
        size: 32,
      ),
    );
  }
}
