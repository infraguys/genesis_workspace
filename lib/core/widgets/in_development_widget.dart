import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

/// Decorative placeholder shown when a section is still being built.
class InDevelopmentWidget extends StatelessWidget {
  const InDevelopmentWidget({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>();
    final t = context.t.inDevelopment;
    final Color outline = theme.colorScheme.outline.withValues(alpha: 0.15);
    final Color descriptionColor =
        textColors?.text50 ?? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.white70;
    final List<String> tips = [
      t.tipOne,
      t.tipTwo,
    ];
    final VoidCallback effectiveBack = onBack ?? () => Navigator.of(context).maybePop();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 600;
        final EdgeInsets padding = EdgeInsets.symmetric(
          horizontal: isCompact ? 24 : 48,
          vertical: isCompact ? 32 : 48,
        );

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.4 : 0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 28),
                    ),
                  ],
                ),
                child: Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Badge(accent: theme.colorScheme.primary),
                      const SizedBox(height: 32),
                      Text(
                        t.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t.subtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: (textColors?.text100 ?? theme.colorScheme.onSurface).withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(color: descriptionColor),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: tips.map((tip) => _InfoPill(text: tip)).toList(growable: false),
                      ),
                      const SizedBox(height: 36),
                      // TextButton.icon(
                      //   onPressed: effectiveBack,
                      //   icon: const Icon(Icons.arrow_back_rounded),
                      //   label: Text(t.cta),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.15),
                  accent.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  accent.withValues(alpha: 0.85),
                ],
              ),
            ),
            child: const Icon(Icons.construction_rounded, color: Colors.white, size: 56),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
