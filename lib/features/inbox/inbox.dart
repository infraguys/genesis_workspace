import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/inbox/bloc/inbox_cubit.dart';
import 'package:genesis_workspace/features/inbox/view/inbox_view.dart';

class Inbox extends StatelessWidget {
  const Inbox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => InboxCubit(), child: InboxView());
  }
}
