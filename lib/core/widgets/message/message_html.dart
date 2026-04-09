import 'package:any_link_preview/any_link_preview.dart';
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
import 'package:html/dom.dart' as dom;

class WorkspaceHtmlFactory extends WidgetFactory {}

class MessageHtml extends StatelessWidget {
  MessageHtml({
    super.key,
    required this.content,
    required this.onSelectedTextChanged,
  });

  final String content;
  final Function(String) onSelectedTextChanged;
  final AppShellController appShellController = getIt<AppShellController>();

  List<String> _extractPreviewLinks() {
    final document = dom.Document.html(content);
    final links = <String>{};

    for (final anchor in document.querySelectorAll('a[href]')) {
      final rawHref = anchor.attributes['href']?.trim();
      if (rawHref == null || rawHref.isEmpty || rawHref.startsWith('/user_uploads/')) {
        continue;
      }

      final uri = parseUrlWithBase(rawHref);
      if (uri == null || !isAllowedUrlScheme(uri, allowContactSchemes: false)) {
        continue;
      }

      if (uri.path.startsWith('/user_uploads/') && !isExternalToBase(uri)) {
        continue;
      }

      links.add(uri.toString());
    }

    return links.take(2).toList(growable: false);
  }

  String _toCssRgba(Color color) {
    final int red = (color.r * 255).round();
    final int green = (color.g * 255).round();
    final int blue = (color.b * 255).round();
    return 'rgba($red, $green, $blue, ${color.a.toStringAsFixed(3)})';
  }

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

  Future<bool> _handleTapUrl(BuildContext context, String? url) async {
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
  }

  Widget _buildTableCell({
    required BuildContext context,
    required ThemeData theme,
    required bool isTabletOrSmaller,
    required dom.Element? cell,
    required bool isHeader,
  }) {
    final TextStyle textStyle =
        (isHeader ? theme.textTheme.labelMedium : theme.textTheme.bodyMedium)?.copyWith(
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
        ) ??
        const TextStyle();

    return Container(
      alignment: Alignment.topLeft,
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: cell == null
          ? const SizedBox.shrink()
          : HtmlWidget(
              cell.innerHtml,
              textStyle: textStyle,
              factoryBuilder: () => WorkspaceHtmlFactory(),
              onTapUrl: (String? url) => _handleTapUrl(context, url),
              customStylesBuilder: (element) {
                if (element.localName == 'p') {
                  return {
                    'margin': '0',
                  };
                }
                return null;
              },
              customWidgetBuilder: (element) {
                return _buildCustomWidget(
                  element: element,
                  context: context,
                  theme: theme,
                  isTabletOrSmaller: isTabletOrSmaller,
                  allowTable: false,
                );
              },
            ),
    );
  }

  Widget _buildMarkdownTable({
    required BuildContext context,
    required ThemeData theme,
    required bool isTabletOrSmaller,
    required dom.Element tableElement,
  }) {
    final rowElements = tableElement.querySelectorAll('tr');
    final tableRows = <({dom.Element row, List<dom.Element> cells})>[];
    for (final row in rowElements) {
      final cells = row.children.where((child) => child.localName == 'th' || child.localName == 'td').toList();
      if (cells.isNotEmpty) {
        tableRows.add((row: row, cells: cells));
      }
    }

    if (tableRows.isEmpty) {
      return const SizedBox.shrink();
    }

    final int maxColumns = tableRows.map((tableRow) => tableRow.cells.length).max;
    final Set<dom.Element> headerRows = tableElement.querySelectorAll('thead tr').toSet();

    final Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.55);
    const Color rowColor = Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(color: borderColor),
                verticalInside: BorderSide(color: borderColor),
              ),
              columnWidths: Map<int, TableColumnWidth>.fromEntries(
                List.generate(maxColumns, (index) => MapEntry(index, const IntrinsicColumnWidth())),
              ),
              children: [
                for (int rowIndex = 0; rowIndex < tableRows.length; rowIndex++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: rowColor,
                    ),
                    children: [
                      for (int colIndex = 0; colIndex < maxColumns; colIndex++)
                        _buildTableCell(
                          context: context,
                          theme: theme,
                          isTabletOrSmaller: isTabletOrSmaller,
                          cell: colIndex < tableRows[rowIndex].cells.length
                              ? tableRows[rowIndex].cells[colIndex]
                              : null,
                          isHeader: headerRows.contains(tableRows[rowIndex].row),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildCustomWidget({
    required dom.Element element,
    required BuildContext context,
    required ThemeData theme,
    required bool isTabletOrSmaller,
    bool allowTable = true,
  }) {
    if (allowTable && element.localName == 'table') {
      return _buildMarkdownTable(
        context: context,
        theme: theme,
        isTabletOrSmaller: isTabletOrSmaller,
        tableElement: element,
      );
    }

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
      final content = element.text;
      return MessageSpoiler(content: content);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrSmaller = currentSize(context) <= .tablet;
    final previewLinks = _extractPreviewLinks();
    final Widget html = HtmlWidget(
      content,
      customStylesBuilder: (element) {
        const Set<String> quoteClasses = {'quote', 'language-quote'};
        bool hasQuoteClass(dom.Element node) => node.classes.any(quoteClasses.contains);
        bool isQuoteCodeNode(dom.Element node) => node.localName == 'code' && hasQuoteClass(node);

        final bool isQuoteCodeBlock = element.localName == 'pre' && element.children.any(isQuoteCodeNode);
        final bool isQuoteElement = element.localName == 'blockquote' || hasQuoteClass(element) || isQuoteCodeBlock;

        if (isQuoteElement) {
          final quoteBorderColor = _toCssRgba(theme.colorScheme.primary.withValues(alpha: 0.72));
          final quoteTextColor = _toCssRgba(theme.colorScheme.onSurface.withValues(alpha: 0.88));
          return {
            'margin': '8px 0',
            'padding': '2px 0 2px 10px',
            'border-left': '3px solid $quoteBorderColor',
            'color': quoteTextColor,
          };
        }

        return null;
      },
      textStyle: TextStyle(overflow: TextOverflow.ellipsis),
      factoryBuilder: () => WorkspaceHtmlFactory(),
      onTapUrl: (String? url) => _handleTapUrl(context, url),
      customWidgetBuilder: (element) {
        return _buildCustomWidget(
          element: element,
          context: context,
          theme: theme,
          isTabletOrSmaller: isTabletOrSmaller,
        );
      },
    );

    final Widget contentWidget = _MessageHtmlWithPreviews(html: html, previewLinks: previewLinks);

    if (platformInfo.isMobile) {
      return contentWidget;
    }

    return SelectionArea(
      onSelectionChanged: (content) {
        onSelectedTextChanged(content?.plainText ?? '');
      },
      contextMenuBuilder: (BuildContext context, SelectableRegionState state) {
        return const SizedBox.shrink();
      },
      child: contentWidget,
    );
  }
}

class _MessageHtmlWithPreviews extends StatelessWidget {
  const _MessageHtmlWithPreviews({required this.html, required this.previewLinks});

  final Widget html;
  final List<String> previewLinks;

  @override
  Widget build(BuildContext context) {
    if (previewLinks.isEmpty) return html;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        html,
        const SizedBox(height: 8),
        ...previewLinks.map((link) => _LinkPreviewCard(link: link)),
      ],
    );
  }
}

class _LinkPreviewCard extends StatelessWidget {
  const _LinkPreviewCard({required this.link});

  final String link;

  Widget _buildFallbackPreviewImage(ThemeData theme) {
    final host = Uri.tryParse(link)?.host;
    final fallbackUrl = host == null || host.isEmpty ? null : 'https://www.google.com/s2/favicons?domain=$host&sz=128';

    if (fallbackUrl == null) {
      return Container(
        color: theme.colorScheme.surfaceContainerHigh,
        child: Icon(Icons.link_rounded, color: theme.colorScheme.onSurfaceVariant),
      );
    }

    return Image.network(
      fallbackUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: theme.colorScheme.surfaceContainerHigh,
          child: Icon(Icons.link_rounded, color: theme.colorScheme.onSurfaceVariant),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnyLinkPreview.builder(
        link: link,
        cache: const Duration(hours: 12),
        placeholderWidget: Container(
          height: 104,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        itemBuilder: (context, metadata, imageProvider, svgImage) {
          final title = (metadata.title ?? '').trim().isNotEmpty
              ? metadata.title!.trim()
              : (metadata.siteName ?? metadata.url ?? link);
          final description = (metadata.desc ?? '').trim();

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              final uri = Uri.tryParse(link);
              if (uri != null) {
                await launchUrlSafely(context, uri);
              }
            },
            child: Container(
              height: 104,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                      child: imageProvider != null
                          ? Image(image: imageProvider, fit: BoxFit.cover)
                          : (svgImage ?? _buildFallbackPreviewImage(theme)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
