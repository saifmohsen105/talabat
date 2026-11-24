import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthController>();
    if (auth.isLoading) return; // prevents double submit (keyboard + button)

    await auth.signIn(
      _email.text.trim(),
      _password.text.trim(),
    );
    if (auth.errorMessage == null && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthController, bool>((a) => a.isLoading);
    final errorMessage =
    context.select<AuthController, String?>((a) => a.errorMessage);

    return AuthScaffold(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                icon: Icons.restaurant_menu_rounded,
                title: 'Welcome back',
                subtitle: 'Sign in to order your favourite meals instantly',
              ),
              AuthErrorBanner(message: errorMessage),

              AppTextField(
                controller: _email,
                label: 'Email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              AuthGap.field,

              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                controller: _password,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              AuthGap.beforeSubmit,

              AppButton(
                label: 'Sign In',
                isLoading: isLoading,
                onPressed: _login,
              ),
              AuthGap.afterSubmit,

              AuthPromptRow(
                prompt: "Don't have an account?",
                actionLabel: 'Create account',
                onPressed: () => context.push('/register'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}