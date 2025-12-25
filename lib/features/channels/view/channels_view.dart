import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart';
import 'package:genesis_workspace/features/channels/view/channel_item.dart';
import 'package:genesis_workspace/features/channels/view/channel_topics.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';

class ChannelsView extends StatefulWidget {
  final int? initialChannelId;
  final String? initialTopicName;
  const ChannelsView({super.key, this.initialChannelId, this.initialTopicName});

  @override
  State<ChannelsView> createState() => ChannelsViewState();
}

class ChannelsViewState extends State<ChannelsView> {
  late final Future _future;
  final GlobalKey _avatarContainerKey = GlobalKey();
  double _measuredWidth = 0;

  static const double desktopChannelsWidth = 400;

  @override
  void initState() {
    _future = context.read<ChannelsCubit>().getChannels(
      initialChannelId: widget.initialChannelId,
      initialTopicName: widget.initialTopicName,
    );
    super.initState();
  }

  void _measureAvatarWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _avatarContainerKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && mounted) {
          _measuredWidth = renderBox.size.width + 16;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ChannelsCubit, ChannelsState>(
      // listenWhen: (prev, next) =>
      //     prev.selectedChannelId != next.selectedChannelId ||
      //     prev.selectedTopic?.name != next.selectedTopic?.name,
      listener: (context, state) {
        // final router = GoRouter.of(shellNavigatorChannelsKey.currentContext!);
        final currentLocation = router.routeInformationProvider.value.location;

        String target;
        if (state.selectedChannelId == null) {
          target = Routes.channels;
        } else if (state.selectedTopic == null) {
          target = '${Routes.channels}/${state.selectedChannelId}';
        } else {
          target = '${Routes.channels}/${state.selectedChannelId}/${state.selectedTopic!.name}';
        }

        if (currentLocation != target) {
          updateBrowserUrlPath(target);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: WorkspaceAppBar(
            title: context.t.navBar.channels,
            leading: state.selectedChannelId != null
                ? IconButton(
                    onPressed: () {
                      context.read<ChannelsCubit>().closeChannel();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        updateBrowserUrlPath(Routes.channels);
                      });
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  )
                : SizedBox(),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
            ),
          ),
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              if (profileState.user != null) {
                context.read<ChannelsCubit>().setSelfUser(profileState.user);
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

                  if (state.channels.isNotEmpty) {
                    _measureAvatarWidth();
                  }

                  final channelsWidth = currentSize(context) > ScreenSize.lTablet
                      ? desktopChannelsWidth
                      : (MediaQuery.sizeOf(context).width - (currentSize(context) > ScreenSize.tablet ? 114 : 0));

                  final double topicsWidth = state.selectedChannelId != null ? channelsWidth - _measuredWidth : 0;

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
                                return ChannelItem(
                                  channel: channel,
                                  index: index,
                                  selectedChannelId: state.selectedChannelId,
                                  avatarContainerKey: _avatarContainerKey,
                                );
                              },
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    color: Theme.of(context).dividerColor.withValues(
                                      alpha:
                                          (currentSize(context) > ScreenSize.lTablet && state.selectedChannelId != null)
                                          ? 0.3
                                          : 0,
                                    ),
                                    width: 1,
                                  ),
                                ),
                              ),
                              constraints: BoxConstraints(maxWidth: topicsWidth),
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
                      (currentSize(context) > ScreenSize.lTablet &&
                              state.selectedChannel != null &&
                              state.selectedChannelId != null)
                          ? Expanded(
                              // key: ValueKey(state.selectedChannelId),
                              child: ChannelChat(
                                channelId: state.selectedChannelId!,
                                topicName: state.selectedTopic?.name,
                                unreadMessagesCount: state.selectedTopic != null
                                    ? state.selectedTopic!.unreadMessages.length
                                    : state.selectedChannel?.unreadMessages.length,
                              ),
                            )
                          : Expanded(child: Center(child: Text(context.t.selectAnyChannel))),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
