import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class PasteBaseUrlView extends StatefulWidget {
  const PasteBaseUrlView({super.key});

  @override
  State<PasteBaseUrlView> createState() => _PasteBaseUrlViewState();
}

class _PasteBaseUrlViewState extends State<PasteBaseUrlView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _submitting = false;
  String? _validationError;

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String? text = data?.text?.trim();
      if (text != null && text.isNotEmpty) {
        setState(() {
          _controller.text = text;
          _controller.selection = TextSelection.collapsed(offset: text.length);
        });
        _validate(text);
      }
    } catch (_) {
      // игнорируем: отсутствие доступа к буферу/формат
    }
  }

  void _validate(String input) {
    final String value = input.trim();

    if (value.isEmpty) {
      _validationError = null;
      setState(() {});
      return;
    }

    final Uri? uri = Uri.tryParse(value);
    final bool isValidHttps = uri != null && uri.hasAuthority && uri.isScheme('https');

    _validationError = isValidHttps ? null : context.t.organizations.addDialog.urlInvalid;
    setState(() {});
  }

  Future<void> _submit() async {
    final String baseUrl = _controller.text.trim();
    if (_submitting) return;

    _validate(baseUrl);
    if (_validationError != null || baseUrl.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await context.read<AuthCubit>().saveBaseUrl(baseUrl: baseUrl);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
        context.go(Routes.auth);
      }
    }
  }

  Future<void> _addGenesisOrg() async {
    setState(() => _submitting = true);
    try {
      await context.read<AuthCubit>().saveBaseUrl(baseUrl: AppConstants.genesisPublicServerUrl);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
        context.go(Routes.auth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ThemeData theme = Theme.of(context);
    final CardColors cardColors = theme.extension<CardColors>()!;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final bool isPending = state.pasteBaseUrlPending;

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.organizations.addDialog.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.organizations.addDialog.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) {
                      final bool hasText = value.text.trim().isNotEmpty;

                      return TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        onChanged: _validate,
                        decoration: InputDecoration(
                          labelText: t.organizations.addDialog.urlLabel,
                          hintText: t.organizations.addDialog.urlHint,
                          errorText: _validationError,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                          suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: t.auth.paste,
                                icon: const Icon(Icons.content_paste_rounded),
                                onPressed: _pasteFromClipboard,
                              ),
                              if (hasText)
                                IconButton(
                                  tooltip: t.auth.clear,
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    setState(_controller.clear);
                                    _validate('');
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) {
                      final bool enabled = value.text.trim().isNotEmpty && _validationError == null && !_submitting;

                      return SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: enabled ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: (_submitting || isPending)
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(t.organizations.addDialog.submit),
                        ).pending(isPending),
                      );
                    },
                  ),
                  if (kDebugMode)
                    TextButton(
                      onPressed: () {
                        context.read<SettingsCubit>().clearLocalDatabase();
                        context.read<SettingsCubit>().clearSharedPreferences();
                      },
                      child: Text("clear data"),
                    ),
                  Divider(
                    color: theme.dividerColor,
                    height: 20,
                  ),
                  Text(
                    t.organizations.addDialog.publicServerDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InkWell(
                    onTap: _addGenesisOrg,
                    borderRadius: .circular(8),
                    child: Container(
                      padding: .all(8),
                      decoration: BoxDecoration(
                        color: cardColors.base.withValues(alpha: .02),
                        borderRadius: .circular(8),
                      ),
                      child: Row(
                        spacing: 8,
                        children: [
                          ClipRRect(
                            borderRadius: .circular(8),
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
        );
      },
    );
  }
}
