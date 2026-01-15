// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:genesis_workspace/core/dependency_injection/di.dart';
// import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
// import 'package:genesis_workspace/features/channels/view/channels_view.dart';
//
// class Channels extends StatelessWidget {
//   final int? initialChannelId;
//   final String? initialTopicName;
//   const Channels({super.key, this.initialChannelId, this.initialTopicName});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<ChannelsCubit>(),
//       child: ChannelsView(initialChannelId: initialChannelId, initialTopicName: initialTopicName),
//     );
//   }
// }
