import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' show LinkPreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
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

  static final RegExp _hrefRegExp = RegExp(
    r'''href=(["'])([^"']+)\1''',
    caseSensitive: false,
  );

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

  String? _extractPreviewUrl(String htmlContent) {
    for (final Match match in _hrefRegExp.allMatches(htmlContent)) {
      final String rawUrl = match.group(2)?.trim() ?? '';
      if (rawUrl.isEmpty) continue;

      final Uri? targetUri = parseUrlWithBase(rawUrl);
      if (targetUri == null) continue;

      if (!isAllowedUrlScheme(targetUri, allowContactSchemes: false)) continue;
      if (!isExternalToBase(targetUri)) continue;
      if (targetUri.path.startsWith('/user_uploads/')) continue;

      return targetUri.toString();
    }

    final String plainText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    final RegExp urlRegExp = RegExp(regexLink, caseSensitive: false, unicode: true);
    final Match? urlMatch = urlRegExp.firstMatch(plainText);
    final String? rawMatch = urlMatch?.group(0)?.trim();
    if (rawMatch == null || rawMatch.isEmpty) return null;

    final String normalizedRaw =
        rawMatch.toLowerCase().startsWith('http://') || rawMatch.toLowerCase().startsWith('https://')
            ? rawMatch
            : 'https://$rawMatch';

    final Uri? targetUri = parseUrlWithBase(normalizedRaw);
    if (targetUri == null) return null;
    if (!isAllowedUrlScheme(targetUri, allowContactSchemes: false)) return null;
    if (!isExternalToBase(targetUri)) return null;
    if (targetUri.path.startsWith('/user_uploads/')) return null;

    return targetUri.toString();
  }

  bool _isSameUrl(String first, String second) {
    final Uri? firstUri = parseUrlWithBase(first);
    final Uri? secondUri = parseUrlWithBase(second);
    if (firstUri == null || secondUri == null) return false;

    String normalized(Uri uri) => uri.replace(fragment: '').toString().replaceFirst(RegExp(r'/$'), '');
    return normalized(firstUri) == normalized(secondUri);
  }

  bool _isOnlyPreviewUrlMessage(String htmlContent, String previewUrl) {
    final String plainText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plainText.isEmpty) return false;
    return _isSameUrl(plainText, previewUrl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrSmaller = currentSize(context) <= .tablet;
    final String? previewUrl = _extractPreviewUrl(content);
    final bool renderOnlyPreview = previewUrl != null && _isOnlyPreviewUrlMessage(content, previewUrl);
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

    final Widget htmlWithSelection =
        platformInfo.isMobile
            ? html
            : SelectionArea(
              onSelectionChanged: (content) {
                onSelectedTextChanged(content?.plainText ?? '');
              },
              contextMenuBuilder: (BuildContext context, SelectableRegionState state) {
                return const SizedBox.shrink();
              },
              child: html,
            );

    if (previewUrl == null) {
      return htmlWithSelection;
    }

    if (renderOnlyPreview) {
      return _MessageLinkPreview(
        url: previewUrl,
        isTabletOrSmaller: isTabletOrSmaller,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        htmlWithSelection,
        const SizedBox(height: 8),
        _MessageLinkPreview(
          url: previewUrl,
          isTabletOrSmaller: isTabletOrSmaller,
        ),
      ],
    );
  }
}

class _MessageLinkPreview extends StatefulWidget {
  const _MessageLinkPreview({
    required this.url,
    required this.isTabletOrSmaller,
  });

  final String url;
  final bool isTabletOrSmaller;

  @override
  State<_MessageLinkPreview> createState() => _MessageLinkPreviewState();
}

class _MessageLinkPreviewState extends State<_MessageLinkPreview> {
  late Future<LinkPreviewData?> _previewFuture;
  bool _previewImageFailed = false;

  @override
  void initState() {
    super.initState();
    _previewFuture = _loadPreview(widget.url);
  }

  Future<LinkPreviewData?> _loadPreview(String url) {
    return getLinkPreviewData(
      url,
      requestTimeout: const Duration(seconds: 8),
      proxy: kIsWeb ? 'https://corsproxy.io/?' : null,
      userAgent:
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
      headers: const {
        'Accept-Language': 'en-US,en;q=0.9,ru;q=0.8',
      },
    );
  }

  @override
  void didUpdateWidget(covariant _MessageLinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _previewImageFailed = false;
      _previewFuture = _loadPreview(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<LinkPreviewData?>(
      future: _previewFuture,
      builder: (context, snapshot) {
        final LinkPreviewData? previewData = snapshot.data;
        final String resolvedUrl = previewData?.link ?? widget.url;
        final Uri? resolvedUri = Uri.tryParse(resolvedUrl);
        final String? faviconUrl =
            (resolvedUri?.host.isNotEmpty ?? false)
                ? 'https://www.google.com/s2/favicons?domain=${resolvedUri!.host}&sz=64'
                : null;
        final bool canShowPreviewImage = previewData?.image != null && !_previewImageFailed;
        final String title = (previewData?.title?.trim().isNotEmpty ?? false)
            ? previewData!.title!.trim()
            : (resolvedUri?.host.isNotEmpty ?? false)
            ? resolvedUri!.host
            : resolvedUrl;
        final String? description =
            (previewData?.description?.trim().isNotEmpty ?? false) ? previewData!.description!.trim() : null;

        return InkWell(
          onTap: () async {
            final Uri? uri = parseUrlWithBase(resolvedUrl);
            if (uri == null || !isAllowedUrlScheme(uri, allowContactSchemes: false)) return;
            await launchUrlSafely(context, uri);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (canShowPreviewImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        previewData!.image!.url,
                        width: widget.isTabletOrSmaller ? 68 : 78,
                        height: widget.isTabletOrSmaller ? 68 : 78,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted || _previewImageFailed) return;
                            setState(() => _previewImageFailed = true);
                          });
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                  ] else ...[
                    if (faviconUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          faviconUrl,
                          width: widget.isTabletOrSmaller ? 68 : 78,
                          height: widget.isTabletOrSmaller ? 68 : 78,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.link_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      Icon(Icons.link_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          resolvedUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
