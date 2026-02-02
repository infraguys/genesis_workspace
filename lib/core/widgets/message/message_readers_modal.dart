import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/messages/bloc/message_readers/message_readers_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:go_router/go_router.dart';

class _MessageReadersModalView extends StatefulWidget {
  const _MessageReadersModalView({super.key}); //ignore: unused_element_parameter

  @override
  State<_MessageReadersModalView> createState() => _MessageReadersModalViewState();
}

class _MessageReadersModalViewState extends State<_MessageReadersModalView> {
  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Dialog(
      child: SizedBox(
        width: 460,
        height: 460,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<MessageReadersCubit, MessageReadersState>(
            builder: (context, state) {
              if (state is! MessageReadersSuccessState) {
                return Center(child: CircularProgressIndicator());
              }
              final users = state.users;
              return Column(
                children: [
                  Text(
                    context.t.messageReadersTitle(n: users.length),
                    style: textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                  const Divider(),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Row(
                          spacing: 12.0,
                          children: [
                            UserAvatar(avatarUrl: user.avatarUrl, size: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    user.fullName,
                                    overflow: .ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    user.email,
                                    overflow: .ellipsis,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(height: 12.0),
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
                          child: Text(context.t.groupChat.createDialog.cancel),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class MessageReadersModal extends StatelessWidget {
  const MessageReadersModal({super.key, required this.messageId});

  final int messageId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MessageReadersCubit>()..getMessageReaders(messageId),
      child: const _MessageReadersModalView(),
    );
  }
}
