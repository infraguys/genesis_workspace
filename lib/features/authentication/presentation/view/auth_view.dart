import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("Workspace"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[const Text('You have pushed the haha this many times:')],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.read<AuthCubit>().login('', '');
            },
            tooltip: 'Increment',
            child: state.isPending ? CircularProgressIndicator() : Icon(Icons.add),
          ),
        );
      },
    );
  }
}
