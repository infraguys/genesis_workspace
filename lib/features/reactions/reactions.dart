import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/reactions/bloc/reactions_cubit.dart';
import 'package:genesis_workspace/features/reactions/view/reactions_view.dart';

import '../../core/dependency_injection/di.dart';

class Reactions extends StatelessWidget {
  const Reactions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => getIt<ReactionsCubit>(), child: ReactionsView());
  }
}
