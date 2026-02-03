import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/mixins/chat/open_chat_mixin.dart';
import 'package:genesis_workspace/features/messenger/bloc/create_chat/create_chat_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class CreateTopicDialog extends StatefulWidget {
  const CreateTopicDialog({super.key, required this.channelId});

  final int? channelId;

  @override
  State<CreateTopicDialog> createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends State<CreateTopicDialog> with OpenChatMixin {
  final  _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final int _maxNameLength;

  @override
  void initState() {
    super.initState();
    final organizationsState = context.read<OrganizationsCubit>().state;
    final org = organizationsState.organizations.firstWhere(
      (org) => org.id == organizationsState.selectedOrganizationId,
    );
    _maxNameLength = org.streamNameMaxLength!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = TextTheme.of(context);
    final textColors = theme.extension<TextColors>()!;
    return Dialog(
      constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
      child: BlocBuilder<CreateChatCubit, CreateChatState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: .min,
              children: [
                Padding(
                  padding: const .fromLTRB(16, 16, 8, 8),
                  child: Text(
                    context.t.topic.newTopic,
                    style: textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const .fromLTRB(12, 12, 12, 8),
                  child: Column(
                    crossAxisAlignment: .start,
                    spacing: 4,
                    children: [
                      Text(
                        context.t.topic.topicName,
                        style: theme.textTheme.labelLarge?.copyWith(color: textColors.text30),
                      ),
                      TextFormField(
                        controller: _nameController,
                        autovalidateMode: .onUserInteraction,
                        validator: (value) {
                          final trimmed = value?.trim();
                          if (trimmed != null && trimmed.isEmpty) {
                            return context.t.topic.requiredNameError;
                          }
                          if (trimmed != null && trimmed.length > _maxNameLength) {
                            return context.t.channel.createDialog.nameMaxLength(max: _maxNameLength);
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: context.t.topic.topicName,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const .all(12),
                  child: Row(
                    mainAxisAlignment: .end,
                    spacing: 8.0,
                    children: [
                      TextButton(
                        onPressed: context.pop,
                        child: Text(t.groupChat.createDialog.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          if(_formKey.currentState!.validate()) {
                            context.pop();
                            openChannel(context, channelId: widget.channelId!, topicName: _nameController.text);
                          }
                        },
                        child: Text(t.groupChat.createDialog.create),
                      ).pending(state is CreateChatPending),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
