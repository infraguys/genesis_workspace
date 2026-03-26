import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class CreateCallDialog extends StatefulWidget {
  final bool startWithVideoMuted;
  final String meetingBaseUrl;
  const CreateCallDialog({
    super.key,
    required this.startWithVideoMuted,
    required this.meetingBaseUrl,
  });

  @override
  State<CreateCallDialog> createState() => _CreateCallDialogState();
}

class _CreateCallDialogState extends State<CreateCallDialog> {
  late final TextEditingController callNameController;
  late final String randomCallName;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    randomCallName = _generateRandomCallName();
    callNameController = TextEditingController();
  }

  @override
  void dispose() {
    callNameController.dispose();
    super.dispose();
  }

  String _generateRandomCallName() {
    const prefixes = ['alpha', 'bravo', 'charlie', 'delta', 'echo', 'foxtrot'];
    const suffixes = ['team', 'sync', 'room', 'standup', 'review', 'meeting'];
    final random = Random();
    final prefix = prefixes[random.nextInt(prefixes.length)];
    final suffix = suffixes[random.nextInt(suffixes.length)];
    final number = 1000 + random.nextInt(9000);
    return '$prefix-$suffix-$number';
  }

  String _buildCallLink() {
    final rawName = callNameController.text.trim().isEmpty ? randomCallName : callNameController.text.trim();
    final sanitizedName = rawName.replaceAll(RegExp(r'\s+'), '-');
    return '${widget.meetingBaseUrl}/$sanitizedName#config.startWithVideoMuted=${widget.startWithVideoMuted}';
  }

  @override
  Widget build(BuildContext context) {
    final translations = context.t.call.createCallDialog;
    final isTabletOrSmaller = currentSize(context) <= .tablet;
    return AlertDialog(
      title: Text(widget.startWithVideoMuted ? translations.title : translations.videoTitle),
      constraints: BoxConstraints(
        minWidth: 350,
        maxWidth: 350,
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: callNameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: translations.nameLabel,
            hintText: randomCallName,
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            final link = _buildCallLink();
            context.pop(link);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(translations.cancel),
        ),
        FilledButton(
          onPressed: () {
            final link = _buildCallLink();
            context.pop(link);
            if (isTabletOrSmaller) {
              context.pushNamed(Routes.call, extra: link);
            } else {
              context.read<CallCubit>().openCall(meetUrl: link, meetLocationName: '');
            }
          },
          child: Text(translations.create),
        ),
      ],
    );
  }
}
