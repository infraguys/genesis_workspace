import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Authorized. This is home page"),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthCubit>().logout();
                context.go(Routes.auth);
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
