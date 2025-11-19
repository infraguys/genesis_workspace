import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/right_side_pane/channel_right_side_panel.dart';
import 'package:genesis_workspace/features/messenger/view/right_side_pane/private_right_side_panel.dart';

class RightSidePanel extends StatelessWidget {
  const RightSidePanel({super.key, required this.onClose, required this.isChannel});

  final VoidCallback onClose;

  final bool isChannel;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ChannelMembersInfoCubit>(),
        ),
      ],
      child: isChannel
          ? ChannelRightSidePanel(onClose: onClose)
          : PrivateRightSidePanel(onClose: onClose),
    );
  }
}
