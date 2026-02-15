import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class AddOrganizationDialog extends StatefulWidget {
  const AddOrganizationDialog({super.key});

  @override
  State<AddOrganizationDialog> createState() => _AddOrganizationDialogState();
}

class _AddOrganizationDialogState extends State<AddOrganizationDialog> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();

  String? _urlError;

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteUrlFromClipboard() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String? text = data?.text?.trim();
      if (text != null && text.isNotEmpty) {
        _urlController
          ..text = text
          ..selection = TextSelection.collapsed(offset: text.length);
        _validateUrl(text);
      }
    } catch (_) {
      // intentionally ignore clipboard errors
    }
  }

  void _validateUrl(String input) {
    final String value = input.trim();

    if (value.isEmpty) {
      _urlError = null;
      setState(() {});
      return;
    }

    final Uri? uri = Uri.tryParse(value);
    final bool isValidHttps = uri != null && uri.hasAuthority && uri.isScheme('https');

    _urlError = isValidHttps ? null : context.t.organizations.addDialog.urlInvalid;
    setState(() {});
  }

  bool get _canSubmit {
    return (_urlController.text.trim().isNotEmpty) && _urlError == null;
  }

  void _submit() {
    _validateUrl(_urlController.text);
    if (!_canSubmit) return;

    Navigator.of(context).pop(_urlController.text.trim());
  }

  void _addGenesisOrg() {
    Navigator.of(context).pop(AppConstants.genesisPublicServerUrl);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ThemeData theme = Theme.of(context);
    final CardColors cardColors = theme.extension<CardColors>()!;
    final BorderRadius borderRadius = BorderRadius.circular(16);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(t.organizations.addDialog.title, style: theme.textTheme.titleLarge),
                    ),
                    IconButton(
                      tooltip: t.general.close,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t.organizations.addDialog.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _urlController,
                  builder: (context, value, _) {
                    final bool hasText = value.text.trim().isNotEmpty;
                    return TextField(
                      controller: _urlController,
                      focusNode: _urlFocusNode,
                      autofocus: true,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onChanged: _validateUrl,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: t.organizations.addDialog.urlLabel,
                        hintText: t.organizations.addDialog.urlHint,
                        errorText: _urlError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIconConstraints: const BoxConstraints(minHeight: 40, minWidth: 40),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: t.auth.paste,
                              icon: const Icon(Icons.content_paste_rounded),
                              onPressed: _pasteUrlFromClipboard,
                            ),
                            if (hasText)
                              IconButton(
                                tooltip: t.auth.clear,
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _urlController.clear();
                                  _validateUrl('');
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(t.organizations.addDialog.submit),
                  ),
                ),
                Divider(
                  color: theme.dividerColor,
                  height: 20,
                ),
                Text(
                  t.organizations.addDialog.publicServerDescription,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _addGenesisOrg,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColors.base.withValues(alpha: .02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Assets.images.genesisLogoPng.image(
                            width: 36,
                            height: 36,
                          ),
                        ),
                        Text(
                          t.organizations.addDialog.publicServerTitle,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
