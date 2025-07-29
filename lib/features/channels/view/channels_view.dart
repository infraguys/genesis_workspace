import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/features/channels/view/channel_topics.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ChannelsView extends StatefulWidget {
  const ChannelsView({super.key});

  @override
  State<ChannelsView> createState() => ChannelsViewState();
}

class ChannelsViewState extends State<ChannelsView> {
  late final Future _future;
  final GlobalKey _avatarContainerKey = GlobalKey();
  double _measuredWidth = 0;

  static const double desktopChannelsWidth = 440;

  @override
  void initState() {
    super.initState();
    _future = context.read<ChannelsCubit>().getChannels();
  }

  void _measureAvatarWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _avatarContainerKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && mounted) {
          _measuredWidth = renderBox.size.width;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.navBar.channels),
        leading: BlocBuilder<ChannelsCubit, ChannelsState>(
          builder: (context, state) {
            if (state.selectedChannelId != null) {
              return IconButton(
                onPressed: () {
                  context.read<ChannelsCubit>().selectChannelId(null);
                },
                icon: Icon(Icons.arrow_back_ios),
              );
            }
            return SizedBox();
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.user != null) {
            context.read<ChannelsCubit>().setSelfUser(state.user);
          }
          return FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Some error..."));
              }

              return BlocBuilder<ChannelsCubit, ChannelsState>(
                builder: (context, state) {
                  if (state.channels.isNotEmpty) {
                    _measureAvatarWidth();
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: currentSize(context) > ScreenSize.lTablet
                              ? desktopChannelsWidth
                              : (MediaQuery.sizeOf(context).width -
                                    (currentSize(context) > ScreenSize.tablet ? 114 : 0)),
                        ),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            ListView.separated(
                              itemCount: state.channels.length,
                              separatorBuilder: (_, _) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final channel = state.channels[index];
                                return InkWell(
                                  highlightColor: theme.colorScheme.primaryContainer,
                                  onTap: () async {
                                    context.read<ChannelsCubit>().selectChannelId(channel.streamId);
                                    await context.read<ChannelsCubit>().getChannelTopics(
                                      streamId: channel.streamId,
                                      unreadMessages: state.unreadMessages,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          spacing: 8,
                                          children: [
                                            AnimatedContainer(
                                              key: index == 0 ? _avatarContainerKey : null,
                                              duration: const Duration(milliseconds: 200),
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: state.selectedChannelId == channel.streamId
                                                    ? theme.colorScheme.primaryContainer
                                                    : null,
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor: parseColor(channel.color),
                                                child: Text(
                                                  channel.name.characters.first.toUpperCase(),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  channel.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (channel.description.isNotEmpty)
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.sizeOf(context).width * 0.8,
                                                    ),
                                                    child: Text(
                                                      channel.description,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Badge.count(
                                          count: channel.unreadMessages.length,
                                          isLabelVisible: channel.unreadMessages.isNotEmpty,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.3), // or any custom color
                                    width: 1, // border thickness
                                  ),
                                ),
                              ),
                              constraints: BoxConstraints(
                                maxWidth: state.selectedChannelId != null
                                    ? (currentSize(context) > ScreenSize.lTablet
                                              ? desktopChannelsWidth
                                              : (MediaQuery.sizeOf(context).width -
                                                    (currentSize(context) > ScreenSize.tablet
                                                        ? 114
                                                        : 0))) -
                                          _measuredWidth
                                    : 0,
                              ),
                              child: ChannelTopics(
                                channel: state.selectedChannelId != null
                                    ? state.channels.firstWhere((channel) {
                                        return channel.streamId == state.selectedChannelId;
                                      })
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentSize(context) > ScreenSize.lTablet &&
                          state.selectedChannel != null)
                        Expanded(
                          child: ChannelChat(
                            extra: ChannelChatExtra(
                              channel: state.selectedChannel!,
                              topicEntity: state.selectedTopic,
                            ),
                          ),
                        ),
                    ],
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
