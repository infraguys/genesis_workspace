import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/palettes/palette.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel/info_panel_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class OpenInfoPanelButton extends StatelessWidget {
  const OpenInfoPanelButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColors = Theme.of(context).extension<IconColors>()!;
    return IconButton(
      onPressed: onPressed,
      icon: BlocBuilder<InfoPanelCubit, InfoPanelState>(
        builder: (context, state) {
          final color = switch (state.status) {
            .closed => iconColors.base,
            _ => iconColors.active,
          };
          return Assets.icons.dock.svg(
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          );
        },
      ),
    );
  }
}
