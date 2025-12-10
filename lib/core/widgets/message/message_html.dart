import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/authorized_image.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/download_files/bloc/download_files_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/app_shell_controller.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkspaceHtmlFactory extends WidgetFactory {}

class MessageHtml extends StatelessWidget {
  final String content;
  MessageHtml({super.key, required this.content});

  final GetUserByIdUseCase _getUserByIdUseCase = getIt<GetUserByIdUseCase>();

  Future<DmUserEntity> getUserById(int userId) async {
    final UserEntity user = await _getUserByIdUseCase.call(userId);
    return user.toDmUser();
  }

  final AppShellController appShellController = getIt<AppShellController>();

  String? _buildImageUrl(String? raw) {
    if (raw == null) return null;
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('/user_uploads/')) {
      if (AppConstants.baseUrl.isEmpty) return null;
      return '${AppConstants.baseUrl}$trimmed';
    }

    final Uri? parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;

    if (!parsed.hasScheme && !parsed.hasAuthority) {
      final Uri? baseUri = Uri.tryParse(AppConstants.baseUrl);
      if (baseUri == null) return null;
      final Uri resolved = baseUri.resolveUri(parsed);
      return resolved.path.startsWith('/user_uploads/') ? resolved.toString() : null;
    }

    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      return parsed.toString();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectionArea(
      contextMenuBuilder: (BuildContext context, SelectableRegionState state) {
        return const SizedBox.shrink();
      },
      child: HtmlWidget(
        content,
        customStylesBuilder: (element) {
          return null;
        },
        textStyle: TextStyle(overflow: TextOverflow.ellipsis),
        factoryBuilder: () => WorkspaceHtmlFactory(),
        onTapUrl: (String? url) async {
          final String rawUrl = url?.trim() ?? '';
          if (rawUrl.isEmpty) return true;

          if (rawUrl.startsWith('/user_uploads/')) {
            await context.read<DownloadFilesCubit>().download(rawUrl);
            return true;
          }

          final Uri? targetUri = parseUrlWithBase(rawUrl);
          if (targetUri == null) return true;

          if (targetUri.path.startsWith('/user_uploads/') && !isExternalToBase(targetUri)) {
            await context.read<DownloadFilesCubit>().download(targetUri.path);
            return true;
          }

          if (isAllowedUrlScheme(targetUri)) {
            await launchUrlSafely(context, targetUri);
          }
          return true;
        },
        customWidgetBuilder: (element) {
          if (element.attributes.containsValue('image/png') || element.attributes.containsValue('image/jpeg')) {
            final src = element.parentNode?.attributes['href'];
            final size = extractDimensionsFromUrl(src ?? '');
            final String? imageUrl = _buildImageUrl(src);
            if (imageUrl == null) return const SizedBox.shrink();
            return AuthorizedImage(
              url: imageUrl,
              width: size?.width,
              height: size?.height,
              fit: BoxFit.contain,
            );
          }
          if (element.classes.contains('emoji')) {
            final emojiUnicode = element.classes
                .firstWhere((className) => className.contains('emoji-'))
                .replaceAll('emoji-', '');

            final emoji = ":${element.attributes['title']!.replaceAll(' ', '_')}:";

            return InlineCustomWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: UnicodeEmojiWidget(
                  emojiDisplay: UnicodeEmojiDisplay(emojiName: emoji, emojiUnicode: emojiUnicode),
                  size: 14,
                ),
              ),
            );
          }
          if (element.classes.contains('user-mention')) {
            final mention = element.nodes[0].text ?? '';
            final mentionChip = Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                mention,
                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
              ),
            );

            if (element.classes.contains('channel-wildcard-mention')) {
              return InlineCustomWidget(child: mentionChip);
            }

            final userIdAttr = element.attributes['data-user-id'];
            final userId = int.tryParse(userIdAttr ?? '');

            if (userId == null) {
              return InlineCustomWidget(child: mentionChip);
            }

            return InlineCustomWidget(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: CustomPopup(
                  rootNavigator: true,
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    width: 200,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FutureBuilder<DmUserEntity>(
                      future: getUserById(userId),
                      builder: (context, AsyncSnapshot<DmUserEntity> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(child: Text(context.t.error));
                          }
                        }
                        final DmUserEntity user = snapshot.data ?? UserEntity.fake().toDmUser();
                        return Skeletonizer(
                          enabled: snapshot.connectionState == ConnectionState.waiting,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserAvatar(avatarUrl: user.avatarUrl),
                              SelectableText(
                                user.fullName,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SelectableText(user.email, style: theme.textTheme.bodySmall),
                              const SizedBox(height: 12),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () {
                                      context.pop();
                                      if (currentSize(context) > ScreenSize.lTablet) {
                                        appShellController.goToBranch(0);
                                        context.read<AllChatsCubit>().selectDmChat(user);
                                      } else {
                                        context.pushNamed(
                                          Routes.chat,
                                          pathParameters: {'userId': user.userId.toString()},
                                          extra: {
                                            'unreadMessagesCount': user.unreadMessages.length,
                                          },
                                        );
                                      }
                                    },
                                    child: Ink(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: theme.colorScheme.outlineVariant),
                                        borderRadius: BorderRadius.circular(6),
                                        color: theme.colorScheme.surface,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Open chat",
                                            style: theme.textTheme.labelLarge!.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            size: 14,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  child: mentionChip,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
