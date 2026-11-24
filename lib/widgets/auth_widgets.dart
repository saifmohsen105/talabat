import 'package:flutter/material.dart';

/// Spacing used across the auth screens.
abstract final class _Gap {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Brand colors. Text/link orange is darker than the icon orange to pass
/// WCAG AA contrast (>= 4.5:1) on light backgrounds.
abstract final class _Brand {
  static const Color tint = Color(0xFFFFE7D5);
  static const Color icon = Colors.deepOrange;
  static final Color link = Colors.deepOrange.shade900;
}

/// Shared page shell: safe area, centered, scrollable, width-constrained.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.onBack,
  });

  final List<Widget> children;

  /// When non-null, a back button is shown in the app bar.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: onBack == null
          ? null
          : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const BackButtonIcon(),
          onPressed: onBack,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: _Gap.lg,
              vertical: _Gap.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand mark + title + subtitle.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: _Brand.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: _Brand.icon),
          ),
        ),
        const SizedBox(height: _Gap.lg),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: _Gap.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: _Gap.xl),
      ],
    );
  }
}

/// Error banner with icon and screen-reader announcement.
/// Renders nothing when [message] is null.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: _Gap.lg),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(_Gap.sm),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 20, color: Colors.red.shade800),
              const SizedBox(width: _Gap.xs),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Password input with a built-in show/hide toggle.
/// The toggle lives in the field's `suffixIcon`, so it is RTL-aware and
/// stays aligned even when error text appears.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onSubmitted: widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(),
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: scheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

/// "Don't have an account? Create account" row.
class AuthPromptRow extends StatelessWidget {
  const AuthPromptRow({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _Brand.link,
            minimumSize: const Size(48, 48),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// Spacing helpers so screens don't use magic numbers.
abstract final class AuthGap {
  static const Widget field = SizedBox(height: _Gap.md);
  static const Widget beforeSubmit = SizedBox(height: _Gap.xl);
  static const Widget afterSubmit = SizedBox(height: _Gap.md);
}