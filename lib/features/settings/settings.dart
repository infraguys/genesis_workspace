import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/settings/view/settings_view.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SettingsCubit(), child: SettingsView());
  }
}
