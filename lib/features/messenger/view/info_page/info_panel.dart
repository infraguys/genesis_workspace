import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/channel_info_panel.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/private_info_panel.dart';

class InfoPanel extends StatelessWidget {
  final VoidCallback onClose;
  const InfoPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ChannelMembersInfoCubit>(),
        ),
      ],
      child: BlocBuilder<InfoPanelCubit, InfoPanelState>(
        builder: (BuildContext context, state) {
          switch (state.status) {
            case .channelInfo:
              return ChannelInfoPanel(onClose: onClose);
            case .dmInfo:
              return PrivateInfoPanel(onClose: onClose);
            case .profileInfo:
              return Container();
            default:
              return Container(
                decoration: BoxDecoration(
                  borderRadius: .circular(12.0),
                  color: theme.colorScheme.surface,
                ),
                child: SizedBox.expand(),
              );
          }
        },
      ),
      // child: Builder(
      //   builder: (BuildContext context) {
      //     switch (panelState) {
      //       case .channelInfo:
      //         return ChannelInfoPanel(onClose: onClose);
      //       case .dmInfo:
      //         return PrivateInfoPanel(onClose: onClose);
      //       case .profile:
      //         return Container();
      //       default:
      //         return Container(
      //           decoration: BoxDecoration(
      //             borderRadius: .circular(12.0),
      //             color: theme.colorScheme.surface,
      //           ),
      //           child: SizedBox.expand(),
      //         );
      //     }
      //   },
      // ),
    );
  }
}
