import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class DirectMessagesView extends StatefulWidget {
  const DirectMessagesView({super.key});

  @override
  State<DirectMessagesView> createState() => _DirectMessagesViewState();
}

class _DirectMessagesViewState extends State<DirectMessagesView> {
  late final Future _future;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _future = context.read<DirectMessagesCubit>().getUsers();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(context.t.navBar.directMessages),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.user != null) {
            context.read<DirectMessagesCubit>().setSelfUser(state.user);
          }
          return FutureBuilder(
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
              return BlocBuilder<DirectMessagesCubit, DirectMessagesState>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final DmUserEntity user = state.users[index];
                      return ListTile(
                        onTap: () {
                          context.pushNamed(Routes.chat, extra: user);
                        },
                        title: Text(user.fullName),
                        subtitle: state.typingUsers.contains(user.userId)
                            ? Text("${context.t.typing}...")
                            : Text(context.t.online),
                        leading: UserAvatar(avatarUrl: user.avatarUrl),
                        trailing: user.unreadMessages.isNotEmpty
                            ? Text(user.unreadMessages.length.toString())
                            : SizedBox(),
                      );
                    },
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
