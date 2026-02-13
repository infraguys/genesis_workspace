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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    callNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    callNameController.dispose();
    super.dispose();
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
          ),
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return translations.nameRequired;
            }
            return null;
          },
          onFieldSubmitted: (_) {
            if (!(formKey.currentState?.validate() ?? false)) return;
            final sanitizedName = callNameController.text.trim().replaceAll(RegExp(r'\s+'), '-');
            final link =
                '${widget.meetingBaseUrl}/$sanitizedName#config.startWithVideoMuted=${widget.startWithVideoMuted}';
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
            if (!(formKey.currentState?.validate() ?? false)) return;
            final sanitizedName = callNameController.text.trim().replaceAll(RegExp(r'\s+'), '-');
            final link =
                '${widget.meetingBaseUrl}/$sanitizedName#config.startWithVideoMuted=${widget.startWithVideoMuted}';
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
