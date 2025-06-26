import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/home/presentation/bloc/home_cubit.dart';
import 'package:genesis_workspace/features/home/presentation/view/home_view.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => HomeCubit(), child: HomeView());
  }
}
