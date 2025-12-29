import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/genesis_services/bloc/genesis_services_cubit.dart';
import 'package:genesis_workspace/features/genesis_services/view/genesis_services_view.dart';

class GenesisServices extends StatelessWidget {
  const GenesisServices({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GenesisServicesCubit>(),
      child: GenesisServicesView(),
    );
  }
}
