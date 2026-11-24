import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<(String, String)> faqs = <(String, String)>[
    (
    'How do I place an order?',
    'Browse the menu, open a product, choose the quantity, add it to your cart, then complete checkout.'
    ),
    (
    'Which payment methods are available?',
    'This starter app currently supports cash on delivery.'
    ),
    (
    'Can I change my order?',
    'Contact the restaurant as soon as possible. Changes may not be possible after preparation starts.'
    ),
    (
    'How can I track my order?',
    'Order tracking is not included in this starter version. Your order is saved to your account.'
    ),
    (
    'Can I cancel an order?',
    'Please contact the restaurant promptly. Cancellation depends on the order status.'
    ),
    (
    'Do I need an account?',
    'Yes. Sign in or create an account before placing an order.'
    ),
    (
    'Is my personal information safe?',
    'Supabase Row Level Security restricts profile and order access to the signed-in owner.'
    ),
    (
    'What if an item is unavailable?',
    'The restaurant should contact you to discuss an alternative or cancellation.'
    ),
    (
    'Can I save multiple addresses?',
    'This starter currently asks for a delivery address at checkout and does not save an address book.'
    ),
    (
    'How do I contact support?',
    'Use the contact details provided by the restaurant or project owner.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently asked questions'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: faqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _FaqTile(
                question: faqs[index].$1,
                answer: faqs[index].$2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      shape: shape.copyWith(side: BorderSide(color: scheme.outlineVariant)),
      child: ExpansionTile(
        // Remove the default divider lines shown when expanded.
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: AlignmentDirectional.centerStart,
        iconColor: Colors.deepOrange.shade900,
        collapsedIconColor: scheme.onSurfaceVariant,
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}