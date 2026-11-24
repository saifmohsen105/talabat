import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthController>();
    if (auth.isLoading) {
      return;
    }

    await auth.signUp(
      name: _fullName.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    if (auth.errorMessage == null && mounted) {
      context.go('/');
    }
  }

  /// Safe back navigation: works even if the screen was opened via deep link.
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthController, bool>((a) => a.isLoading);
    final errorMessage =
    context.select<AuthController, String?>((a) => a.errorMessage);

    return AuthScaffold(
      onBack: _goBack,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                icon: Icons.person_add_rounded,
                title: 'Create account',
                subtitle: 'Join us and get your favourite meals delivered fast',
              ),
              AuthErrorBanner(message: errorMessage),

              AppTextField(
                controller: _fullName,
                label: 'Full name',
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              AuthGap.field,

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
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  // Add regex for uppercase, digits, or special characters
                  if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                    return 'Must include at least one uppercase letter and one number';
                  }
                  return null; // Return null if validation passes
                },
              ),

              AuthGap.field,

              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                controller: _confirmPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  if(value != _password.text) {
                    return "Passwords do not match";
                  }
                  return null; // Return null if validation passes
                },
              ),
              AuthGap.beforeSubmit,

              AppButton(
                label: 'Sign Up',
                isLoading: isLoading,
                onPressed: _register,
              ),
              AuthGap.afterSubmit,

              AuthPromptRow(
                prompt: 'Already have an account?',
                actionLabel: 'Sign in',
                onPressed: _goBack,
              ),
            ],
          ),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}