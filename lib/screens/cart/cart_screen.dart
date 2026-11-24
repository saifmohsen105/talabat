import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/cart_controller.dart';
import '../../widgets/async_state.dart';
import '../../widgets/cart_sheet.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final items = cart.items.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        scrolledUnderElevation: 0,
      ),
      body: cart.isEmpty
          ? const EmptyView(
        message: 'Your cart is empty. Add something delicious!',
      )
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final item in items) ...[
            _CartItemTile(
              name: item.product.name,
              imageUrl: item.product.imageUrl,
              lineTotal: item.lineTotal.toStringAsFixed(0),
              quantity: item.quantity,
              onDecrement: () =>
                  cart.setQuantity(item.product.id, item.quantity - 1),
              onIncrement: () =>
                  cart.setQuantity(item.product.id, item.quantity + 1),
              onRemove: () => cart.remove(item.product.id),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          const CartSheet(),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => context.push('/checkout'),
          child: const Text(
            'Continue to checkout',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.name,
    required this.imageUrl,
    required this.lineTotal,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  });

  final String name;
  final String imageUrl;
  final String lineTotal;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  static const double _imageSize = 80;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: _imageSize,
                height: _imageSize,
                fit: BoxFit.cover,
                semanticLabel: name,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: _imageSize,
                  height: _imageSize,
                  child: ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.fastfood,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lineTotal EGP',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _QuantityControl(
                    quantity: quantity,
                    onDecrement: onDecrement,
                    onIncrement: onIncrement,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove $name from cart',
              onPressed: onRemove,
              icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Decrease quantity',
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        Semantics(
          liveRegion: true,
          label: 'Quantity $quantity',
          child: ExcludeSemantics(
            child: SizedBox(
              width: 28,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Increase quantity',
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    );
  }
}