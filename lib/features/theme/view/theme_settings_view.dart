import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/theme/bloc/theme_cubit.dart';

class ThemeSettingsView extends StatelessWidget {
  const ThemeSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final cubit = context.read<ThemeCubit>();
          final isDark = state.themeMode == ThemeMode.dark;
          return ListView(
            children: [
              ListTile(
                title: Text(
                  'Theme',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                title: Text(isDark ? 'Dark mode' : 'Light mode'),
                value: isDark,
                onChanged: (value) {
                  cubit.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Palette',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              ...state.availablePalettes.map((palette) {
                final colorScheme = palette.palette.colorSchemeFor(
                  isDark ? Brightness.dark : Brightness.light,
                );
                final isSelected = state.selectedPaletteId == palette.paletteId;
                return ListTile(
                  leading: _PalettePreview(colorScheme: colorScheme),
                  title: Text(palette.title),
                  trailing: isSelected ? const Icon(Icons.check_circle) : null,
                  onTap: () => cubit.setPalette(palette.paletteId),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _PalettePreview extends StatelessWidget {
  const _PalettePreview({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PreviewCircle(color: colorScheme.primary),
        const SizedBox(width: 6),
        _PreviewCircle(color: colorScheme.surface),
        const SizedBox(width: 6),
        _PreviewCircle(color: colorScheme.onSurface),
      ],
    );
  }
}

class _PreviewCircle extends StatelessWidget {
  const _PreviewCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}
