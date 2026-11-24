import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/cart_controller.dart';
import '../../state/products_controller.dart';
import '../../widgets/async_state.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({required this.productId, super.key});

  final String productId;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantity = 1;

  void _decrement() => setState(() => _quantity--);
  void _increment() => setState(() => _quantity++);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductsController>();

    if (controller.isLoading) {
      return const Scaffold(body: LoadingView());
    }
    final errorMessage = controller.errorMessage;
    if (errorMessage != null) {
      return Scaffold(
        body: ErrorView(message: errorMessage, onRetry: controller.load),
      );
    }
    final product = controller.findProduct(widget.productId);
    if (product == null) {
      return const Scaffold(
        body: EmptyView(message: 'This product is no longer available.'),
      );
    }

    final theme = Theme.of(context);
    final total = (product.price * _quantity).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ProductImage(url: product.imageUrl, label: product.name),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(
              product.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${product.price.toStringAsFixed(0)} EGP',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.deepOrange.shade900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _QuantityStepper(
            quantity: _quantity,
            onDecrement: _quantity > 1 ? _decrement : null,
            onIncrement: _increment,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            context.read<CartController>().add(product, quantity: _quantity);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('${product.name} added to cart')),
              );
          },
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text(
            'Add to cart · $total EGP',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

/// Product image with a stable aspect ratio, a loading placeholder and an
/// error fallback.
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget placeholder(Widget child) => ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(child: child),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          semanticLabel: label,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return placeholder(const CircularProgressIndicator());
          },
          errorBuilder: (_, __, ___) => placeholder(
            Icon(
              Icons.fastfood,
              size: 56,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Label on the left, minus / count / plus on the right (RTL-aware).
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Quantity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Decrease quantity',
          onPressed: onDecrement,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 52,
          child: Semantics(
            liveRegion: true,
            label: 'Quantity $quantity',
            child: ExcludeSemantics(
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Increase quantity',
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}