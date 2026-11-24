import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cart_controller.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cart, _) => Badge(
        isLabelVisible: cart.itemCount > 0,
        label: Text('${cart.itemCount}'),
        child: IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.shopping_bag_outlined),
          tooltip: 'Cart',
        ),
      ),
    );
  }
}
