import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<_InfoItem> _features = [
    _InfoItem(
      icon: Icons.restaurant_menu_rounded,
      title: 'Discover meals',
      subtitle: 'Browse categories, featured dishes and popular picks.',
    ),
    _InfoItem(
      icon: Icons.search_rounded,
      title: 'Find what you like',
      subtitle: 'Search dishes and filter the menu by category.',
    ),
    _InfoItem(
      icon: Icons.shopping_bag_outlined,
      title: 'Build your cart',
      subtitle: 'Choose quantities and review your order before checkout.',
    ),
    _InfoItem(
      icon: Icons.my_location_rounded,
      title: 'Quick delivery address',
      subtitle: 'Detect your current location to fill in your address.',
    ),
    _InfoItem(
      icon: Icons.payments_outlined,
      title: 'Cash on delivery',
      subtitle: 'Place your order now and pay when it arrives.',
    ),
  ];

  static const List<_InfoItem> _technology = [
    _InfoItem(
      icon: Icons.phone_android_rounded,
      title: 'Built with Flutter',
      subtitle: 'Material 3 interface',
    ),
    _InfoItem(
      icon: Icons.storage_rounded,
      title: 'Powered by Supabase',
      subtitle: 'Authentication, PostgreSQL and Row Level Security',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Foodie'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: const [
                _AboutHeader(),
                SizedBox(height: 28),
                _InfoSection(title: 'What you can do', items: _features),
                SizedBox(height: 24),
                _InfoSection(title: 'Built with', items: _technology),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

/// Brand mark, app name, tagline and short description.
class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE7D5),
              shape: BoxShape.circle,
            ),
            child: const ExcludeSemantics(
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 48,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Foodie',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Good food. Simple ordering.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange.shade900,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Foodie is a simple food-delivery demo inspired by modern food '
              'ordering apps. Discover meals, build a cart, and place an order '
              'with cash on delivery.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Titled card containing a list of icon rows separated by dividers.
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});

  final String title;
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 16,
                    color: scheme.outlineVariant,
                  ),
                _InfoRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7D5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExcludeSemantics(
              child: Icon(
                item.icon,
                size: 22,
                color: Colors.deepOrange.shade900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}