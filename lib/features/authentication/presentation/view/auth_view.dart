import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/config/helpers.dart';
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

  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      if (height != 0) {
        context.read<EmojiKeyboardCubit>().setHeight(height);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _keyboardHeightPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (BuildContext context, state) {
        if (state.isAuthorized) {
          context.go(Routes.directMessages);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  GenesisLogo(size: 90),
                  TextFormField(
                    controller: _usernameController,
                    autofillHints: [AutofillHints.email],
                    onTapOutside: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(hintText: "user@tokens.team", label: Text("Email")),
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    autofillHints: [AutofillHints.password],

                    controller: _passwordController,
                    obscureText: _obscureText,
                    onTapOutside: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t.passwordCantBeEmpty;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: context.t.password,
                      hintText: 'cucumber123',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                        onPressed: _toggleVisibility,
                      ),
                    ),
                  ),
                  if (state.errorMessage != null)
                    Text(state.errorMessage!, style: TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await context.read<AuthCubit>().login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                      }
                    },
                    child: Text(context.t.login),
                  ).pending(state.isPending),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
