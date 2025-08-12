import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/starred/bloc/starred_cubit.dart';
import 'package:genesis_workspace/features/starred/view/starred_view.dart';

class Starred extends StatelessWidget {
  const Starred({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => getIt<StarredCubit>(), child: StarredView());
  }
}
