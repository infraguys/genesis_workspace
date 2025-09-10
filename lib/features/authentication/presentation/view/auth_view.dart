import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/genesis_logo.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFocus = FocusNode();

  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  bool _obscureText = true;

  void _toggleVisibility() => setState(() => _obscureText = !_obscureText);

  static const double _maxFormWidth = 420;
  static const double _cardPadding = 24;
  late final Future _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AuthCubit>().getServerSettings();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      if (height != 0) {
        context.read<EmojiKeyboardCubit>().setHeight(height);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    _keyboardHeightPlugin.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthCubit>().login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        inspect(state);
        if (state.isAuthorized) context.go(Routes.directMessages);
        if (!state.hasBaseUrl) context.go(Routes.pasteBaseUrl);
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final isWide = currentSize(context) >= ScreenSize.lTablet;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: FutureBuilder(
            future: _future,
            builder: (BuildContext context, snapshot) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: _maxFormWidth),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: EdgeInsets.all(isWide ? _cardPadding : 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isWide
                                  ? [
                                      BoxShadow(
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                        color: Colors.black.withOpacity(0.08),
                                      ),
                                    ]
                                  : null,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                              ),
                            ),
                            child: AutofillGroup(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  spacing: 12,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(height: 20),
                                        if (snapshot.connectionState == ConnectionState.waiting)
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Center(child: CupertinoActivityIndicator()),
                                          ),
                                      ],
                                    ),
                                    const GenesisLogo(size: 90),
                                    if (state.currentBaseUrl != null) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            t.auth.currentBaseUrl,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            state.currentBaseUrl!,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant, // secondary цвет
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                    ],
                                    Text(
                                      t.login,
                                      // textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _usernameController,
                                      autofillHints: const [AutofillHints.email],
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: t.auth.emailHint,
                                        labelText: t.auth.emailLabel,
                                      ),
                                      validator: validateEmail,
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      autofillHints: const [AutofillHints.password],
                                      obscureText: _obscureText,
                                      obscuringCharacter: '•',
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _submit(),
                                      decoration: InputDecoration(
                                        labelText: t.password,
                                        hintText: t.auth.passwordHint,
                                        suffixIcon: Semantics(
                                          label: _obscureText
                                              ? t.auth.showPassword
                                              : t.auth.hidePassword,
                                          button: true,
                                          child: IconButton(
                                            icon: Icon(
                                              _obscureText
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                            onPressed: _toggleVisibility,
                                            tooltip: _obscureText
                                                ? t.auth.showPassword
                                                : t.auth.hidePassword,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.isEmpty) ? t.passwordCantBeEmpty : null,
                                    ),
                                    if (state.errorMessage != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
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
                                                state.errorMessage!,
                                                style: TextStyle(
                                                  color: theme.colorScheme.onErrorContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: state.isPending ? null : _submit,
                                        child: Text(t.login),
                                      ).pending(state.isPending),
                                    ),
                                    // SizedBox(
                                    //   height: 48,
                                    //   child: ElevatedButton(
                                    //     onPressed: context.read<AuthCubit>().setLogin,
                                    //     child: Text('set login'),
                                    //   ),
                                    // ),
                                    if (state.serverSettings != null &&
                                        snapshot.connectionState == ConnectionState.done)
                                      ...state.serverSettings!.externalAuthenticationMethods.map(
                                        (realm) => SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final url = realm.loginUrl;
                                              await context.read<AuthCubit>().startOidcMobileFlow(
                                                realmBaseUrl: state.serverSettings!.realmUri,
                                                loginPath: url,
                                              );
                                              await context.pushNamed(Routes.pasteToken);
                                            },
                                            child: Text(
                                              t.auth.loginWith(realmName: realm.displayName),
                                            ),
                                          ),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 44,
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.logout_rounded),
                                        label: Text(t.auth.logoutFromOrganization),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: theme.colorScheme.error,
                                          side: BorderSide(color: theme.colorScheme.error),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await context.read<AuthCubit>().clearBaseUrl();
                                          if (context.mounted) {
                                            context.go(Routes.pasteBaseUrl);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
