import 'package:flutter/material.dart';

abstract final class _Brand {
  static const Color tint = Color(0xFFFFE7D5);
  static const Color icon = Colors.deepOrange;
  // Darker shades pass WCAG AA with white / on light surfaces.
  static final Color banner = Colors.deepOrange.shade800;
  static final Color link = Colors.deepOrange.shade900;
}

/// Section title with an optional "See all" action.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
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
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: _Brand.link,
              minimumSize: const Size(48, 48),
            ),
            child: const Text(
              'See all',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

/// Promotional banner. Solid brand color (no gradient or glow).
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _Brand.banner,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _Brand.link,
                    minimumSize: const Size(48, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onAction,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ExcludeSemantics(
            child: Icon(
              Icons.fastfood_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only search field that acts as a button to open the shop.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    super.key,
    required this.hint,
    required this.onTap,
  });

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search_rounded, color: _Brand.link),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

/// Circular category entry used in the horizontal categories list.
class HomeCategoryItem extends StatelessWidget {
  const HomeCategoryItem({
    super.key,
    required this.name,
    required this.onTap,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: _Brand.tint,
              backgroundImage: url == null ? null : NetworkImage(url),
              child: url == null
                  ? const Icon(Icons.fastfood, color: _Brand.icon)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling list with a fixed height and consistent spacing.
class HomeHorizontalRail extends StatelessWidget {
  const HomeHorizontalRail({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.itemWidth,
  });

  final double height;
  final double? itemWidth;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final child = itemBuilder(context, index);
          return itemWidth == null
              ? child
              : SizedBox(width: itemWidth, child: child);
        },
      ),
    );
  }
}

/// Location chip shown in the app bar.
class HomeDeliveryLocation extends StatelessWidget {
  const HomeDeliveryLocation({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: _Brand.tint,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_pin, color: _Brand.icon, size: 20),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deliver to',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}