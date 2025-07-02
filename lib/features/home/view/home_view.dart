import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/home/bloc/home_cubit.dart';
import 'package:genesis_workspace/features/home/view/user_avatar.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final Future _future;

  @override
  void initState() {
    _future = context.read<HomeCubit>().getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Some error..."));
            }
          }
          return BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (BuildContext context, int index) {
                  final UserEntity user = state.users[index];
                  return ListTile(
                    onTap: () {
                      context.pushNamed(Routes.chat, extra: user);
                    },
                    title: Text(user.fullName),
                    subtitle: state.typingUsers.contains(user.userId)
                        ? Text("Typing...")
                        : Text("Online"),
                    leading: UserAvatar(avatarUrl: user.avatarUrl),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
