import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: WorkspaceAppBar(title: context.t.navBar.menu),
      body: ListView(
        children: [
          ListTile(
            title: Text(context.t.feed),
            leading: Icon(Icons.feed),
            trailing: Icon(Icons.arrow_right),
            onTap: () async {
              await context.pushNamed(Routes.feed);
            },
          ),
          ListTile(
            title: Text(context.t.inbox.title),
            leading: Icon(Icons.inbox),
            trailing: Icon(Icons.arrow_right),
            onTap: () async {
              await context.pushNamed(Routes.inbox);
            },
          ),
          ListTile(
            title: Text(context.t.mentions.title),
            leading: Icon(Icons.alternate_email),
            trailing: Icon(Icons.arrow_right),
            onTap: () async {
              await context.pushNamed(Routes.mentions);
            },
          ),
          ListTile(
            title: Text(context.t.reactions.title),
            leading: Icon(Icons.emoji_emotions_rounded),
            trailing: Icon(Icons.arrow_right),
            onTap: () async {
              await context.pushNamed(Routes.reactions);
            },
          ),
          ListTile(
            title: Text(context.t.starred.title),
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_right),
            onTap: () async {
              await context.pushNamed(Routes.starred);
            },
          ),
        ],
      ),
    );
  }
}
