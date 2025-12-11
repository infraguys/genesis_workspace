import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
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

    _validationError = isValidHttps ? null : context.t.auth.baseUrlInvalid;
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

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ThemeData theme = Theme.of(context);

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
                  Text(t.auth.enterOrPasteBaseUrlTitle, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.baseUrlUsageHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          labelText: t.auth.baseUrlLabel, // добавьте ключ
                          hintText: t.auth.baseUrlHint,
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
                  const SizedBox(height: 16),
                  if (kDebugMode)
                    TextButton(
                      onPressed: () {
                        context.read<SettingsCubit>().clearLocalDatabase();
                        context.read<SettingsCubit>().clearSharedPreferences();
                      },
                      child: Text("clear data"),
                    ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) {
                      final bool enabled =
                          value.text.trim().isNotEmpty && _validationError == null && !_submitting;

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
                              : Text(t.auth.saveAndContinue),
                        ).pending(isPending),
                      );
                    },
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
