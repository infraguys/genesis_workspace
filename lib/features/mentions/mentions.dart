import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/mentions/bloc/mentions_cubit.dart';
import 'package:genesis_workspace/features/mentions/view/mentions_view.dart';

class Mentions extends StatelessWidget {
  const Mentions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => MentionsCubit(), child: MentionsView());
  }
}
