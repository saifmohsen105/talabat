import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/auth_controller.dart';
import '../../state/products_controller.dart';
import '../../widgets/async_state.dart';
import '../../widgets/cart_widget.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _railHeight = 220;
  static const double _cardWidth = 160;

  Future<void> _onMenuSelected(BuildContext context, String value) async {
    if (value == 'signout') {
      await context.read<AuthController>().signOut();
      if (context.mounted) {
        context.go('/login');
      };
    } else {
      context.push('/$value');
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsController>();
    final scheme = Theme.of(context).colorScheme;

    final featured = products.products.where((p) => p.isFeatured).toList();
    final popular = products.products.where((p) => p.isPopular).toList();
    final errorMessage = products.errorMessage;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const HomeDeliveryLocation(location: 'Cairo, Egypt'),
        actions: [
          CartWidget(onTap: () => context.push('/cart')),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: PopupMenuButton<String>(
              tooltip: 'More options',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _onMenuSelected(context, value),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'faqs', child: Text('FAQs')),
                const PopupMenuItem(value: 'about', child: Text('About')),
                PopupMenuItem(
                  value: 'signout',
                  child: Text(
                    'Sign out',
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: products.isLoading
          ? const LoadingView(label: 'Loading delicious food...')
          : errorMessage != null
          ? ErrorView(message: errorMessage, onRetry: products.load)
          : RefreshIndicator(
        color: scheme.primary,
        onRefresh: products.load,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          children: [
            HomeHeroBanner(
              title: 'Hungry?',
              subtitle:
              'Get your favorite food delivered fast to your doorstep.',
              actionLabel: 'Order Now',
              onAction: () => context.push('/shop'),
            ),
            const SizedBox(height: 20),
            HomeSearchField(
              hint: 'Search restaurants and dishes...',
              onTap: () => context.push('/shop'),
            ),
            const SizedBox(height: 24),

            // Categories
            HomeSectionHeader(
              title: 'Categories',
              onSeeAll: () => context.push('/shop'),
            ),
            const SizedBox(height: 8),
            if (products.categories.isEmpty)
              const SizedBox(
                height: 96,
                child: EmptyView(message: 'No categories yet.'),
              )
            else
              HomeHorizontalRail(
                height: 100,
                itemCount: products.categories.length,
                itemBuilder: (context, index) {
                  final category =
                  products.categories[index];
                  return HomeCategoryItem(
                    name: category.name,
                    imageUrl: category.imageUrl,
                    onTap: () => context
                        .push('/shop?category=${category.id}'),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Featured
            if (featured.isNotEmpty) ...[
              HomeSectionHeader(
                title: 'Featured dishes',
                onSeeAll: () => context.push('/shop'),
              ),
              const SizedBox(height: 8),
              HomeHorizontalRail(
                height: _railHeight,
                itemWidth: _cardWidth,
                itemCount: featured.length,
                itemBuilder: (_, i) =>
                    ProductCard(product: featured[i]),
              ),
              const SizedBox(height: 24),
            ],

            // Popular
            if (popular.isNotEmpty) ...[
              const HomeSectionHeader(title: 'Popular picks'),
              const SizedBox(height: 8),
              HomeHorizontalRail(
                height: _railHeight,
                itemWidth: _cardWidth,
                itemCount: popular.length,
                itemBuilder: (_, i) =>
                    ProductCard(product: popular[i]),
              ),
              const SizedBox(height: 24),
            ],

            if (featured.isEmpty && popular.isEmpty) ...[
              const EmptyView(
                message: 'No products available yet.',
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}