import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cart_controller.dart';

class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    if (cart.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(28),
        child: Text('Your cart is empty.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...cart.items.map((item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.product.name),
                subtitle: Text('${item.quantity} × ${item.product.price.toStringAsFixed(0)} EGP'),
                trailing: Text('${item.lineTotal.toStringAsFixed(0)} EGP'),
              )),
          const Divider(),
          ListTile(
            title: const Text('Total'),
            trailing: Text('${cart.total.toStringAsFixed(0)} EGP',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
