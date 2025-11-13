import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class PasteCodeView extends StatefulWidget {
  const PasteCodeView({super.key});

  @override
  State<PasteCodeView> createState() => _PasteCodeViewState();
}

class _PasteCodeViewState extends State<PasteCodeView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text != null && text.isNotEmpty) {
        setState(() {
          _controller.text = text;
          _controller.selection = TextSelection.collapsed(offset: text.length);
        });
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    try {
      await context.read<AuthCubit>().parsePastedZulipCode(pastedText: code);
      await context.read<RealTimeCubit>().addConnection();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(t.auth.pasteYourCodeHere)),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(t.auth.enterOrPasteCodeTitle, style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            t.auth.codeUsageHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (context, value, _) {
                              final hasText = value.text.trim().isNotEmpty;
                              return TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                autofocus: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: t.auth.tokenLabel,
                                  hintText: t.auth.tokenHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.colorScheme.primary),
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minHeight: 0,
                                    minWidth: 0,
                                  ),
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
                                          onPressed: () => setState(_controller.clear),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          if (state.parseTokenError != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.parseTokenError!,
                                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (context, value, _) {
                              final enabled = value.text.trim().isNotEmpty && !_submitting;
                              return SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: enabled ? _submit : null,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(t.login), // top-level key
                                ).pending(state.isParseTokenPending),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
