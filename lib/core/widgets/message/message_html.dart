import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/core/widgets/authorized_image.dart';
import 'package:genesis_workspace/core/widgets/authorized_media.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/core/widgets/message/message_spoiler.dart';
import 'package:genesis_workspace/core/widgets/message/user_popup_profile.dart';
import 'package:genesis_workspace/domain/download_files/entities/download_file_entity.dart';
import 'package:genesis_workspace/features/download_files/bloc/download_files_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/app_shell_controller.dart';

class WorkspaceHtmlFactory extends WidgetFactory {}

class MessageHtml extends StatelessWidget {
  final String content;
  final Function(String) onSelectedTextChanged;
  MessageHtml({super.key, required this.content, required this.onSelectedTextChanged});

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

  String? _buildThumbnailUrl(String? raw) {
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
    final isTabletOrSmaller = currentSize(context) <= .tablet;
    final Widget html = HtmlWidget(
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
        if (element.attributes.containsValue('image/png') ||
            element.attributes.containsValue('image/jpeg') ||
            element.attributes.containsValue('image/gif') ||
            element.attributes.containsValue('image/webp')) {
          final src = element.parentNode?.attributes['href'];
          final thumbnailSrc = element.attributes['src'];
          final size = extractDimensionsFromUrl(thumbnailSrc ?? '');
          final String? imageUrl = _buildImageUrl(src);
          final String thumbnailUrl = _buildThumbnailUrl(thumbnailSrc) ?? '';
          if (imageUrl == null) return const SizedBox.shrink();
          return AuthorizedImage(
            url: imageUrl,
            thumbnailUrl: thumbnailUrl.isEmpty ? imageUrl : thumbnailUrl,
            width: size?.width,
            height: isTabletOrSmaller ? null : size?.height,
            fit: isTabletOrSmaller ? .fitWidth : .contain,
          );
        }

        if (element.attributes.containsKey('href') &&
            element.attributes.values.any((value) => value.contains('/user_uploads/')) &&
            !element.attributes.containsKey('title')) {
          final String fileUrl = element.attributes['href'] ?? '';
          final String rawFileName = element.nodes.first.parentNode?.text ?? 'File';
          final fileExtension = extractFileExtension(fileUrl);

          if (AppConstants.prioritizedVideoFileExtensions.contains(fileExtension)) {
            return AuthorizedMedia(fileUrl: fileUrl);
          }

          return BlocBuilder<DownloadFilesCubit, DownloadFilesState>(
            builder: (context, state) {
              final file = state.files.firstWhereOrNull((file) => file.pathToFile == fileUrl);
              final bool isDownloaded = file is DownloadedFileEntity;
              final bool isDownloading = file is DownloadingFileEntity;
              return InkWell(
                onTap: () async {
                  if (isDownloaded) {
                    await context.read<DownloadFilesCubit>().openFile(file.localFilePath);
                  } else if (!isDownloading) {
                    await context.read<DownloadFilesCubit>().download(fileUrl);
                  }
                },
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 220,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        color: isDownloaded ? AppColors.green : theme.colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          rawFileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                      const SizedBox(width: 6),
                      isDownloading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                value: file.progress / file.total,
                              ),
                            )
                          : Icon(
                              isDownloaded ? Icons.check : Icons.arrow_downward_rounded,
                              size: 18,
                              color: isDownloaded ? AppColors.green : theme.colorScheme.primary,
                            ),
                    ],
                  ),
                ),
              );
            },
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: UserPopupProfile(userId: userId),
                ),
                child: mentionChip,
              ),
            ),
          );
        }
        if (element.classes.contains('spoiler-header')) {
          return Column(
            children: [
              InlineCustomWidget(
                child: Text(
                  "${context.t.contextMenu.spoiler}: ${element.text.replaceAll('\n', '')}",
                  style: theme.textTheme.labelMedium,
                ),
              ),
              SizedBox(
                height: 2,
              ),
            ],
          );
        }
        if (element.classes.contains('spoiler-content')) {
          final _content = element.text;
          return MessageSpoiler(content: _content);
        }
        return null;
      },
    );

    if (platformInfo.isMobile) {
      return html;
    }

    return SelectionArea(
      onSelectionChanged: (content) {
        onSelectedTextChanged(content?.plainText ?? '');
      },
      contextMenuBuilder: (BuildContext context, SelectableRegionState state) {
        return const SizedBox.shrink();
      },
      child: html,
    );
  }
}
