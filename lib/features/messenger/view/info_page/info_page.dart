import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/channel_info_page.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/channel_info_panel.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/private_info_page.dart';
import 'package:genesis_workspace/features/messenger/view/info_page/private_info_panel.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/shared/widgets/appbar_container.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.isChannel});

  final bool isChannel;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ChannelMembersInfoCubit>(),
        ),
      ],
      child: isChannel ? ChannelInfoPage() : PrivateInfoPage(),
    );
  }
}
