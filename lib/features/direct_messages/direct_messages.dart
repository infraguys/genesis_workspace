import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/direct_messages/view/direct_messages_view.dart';

class DirectMessages extends StatelessWidget {
  const DirectMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DirectMessagesCubit(), child: DirectMessagesView());
  }
}
