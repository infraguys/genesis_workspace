import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/features/channels/view/channels_view.dart';

class Channels extends StatelessWidget {
  const Channels({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ChannelsCubit(), child: ChannelsView());
  }
}
