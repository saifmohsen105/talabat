import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartController extends ChangeNotifier {
  final CartService _cartService = CartService();
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.values.fold(0, (sum, item) => sum + item.lineTotal);
  bool get isEmpty => _items.isEmpty;

  StreamSubscription<AuthState>? _authSub;

  CartController() {

    if (Supabase.instance.client.auth.currentUser != null) {
      loadCart();
    }

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          loadCart();
          break;
        case AuthChangeEvent.signedOut:
          clear();
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> add(Product product, {int quantity = 1}) async {
    final existing = _items[product.id];
    final newQuantity = existing == null ? quantity : existing.quantity + quantity;

    _items[product.id] = existing == null
        ? CartItem(product: product, quantity: quantity)
        : existing.copyWith(quantity: newQuantity);
    notifyListeners();

    try {
      await _cartService.syncAddToCart(product.id, newQuantity);
    } catch (e) {
      debugPrint('Error syncing cart add: $e');
    }
  }

  Future<void> setQuantity(String productId, int quantity) async {
    if (!_items.containsKey(productId)) return;

    if (quantity <= 0) {
      _items.remove(productId);
      notifyListeners();
      try {
        await _cartService.syncRemoveItem(productId);
      } catch (e) {
        debugPrint('Error syncing cart removal: $e');
      }
    } else {
      _items[productId] = _items[productId]!.copyWith(quantity: quantity);
      notifyListeners();
      try {
        await _cartService.syncAddToCart(productId, quantity);
      } catch (e) {
        debugPrint('Error syncing cart quantity update: $e');
      }
    }
  }

  Future<void> remove(String productId) async {
    _items.remove(productId);
    notifyListeners();

    try {
      await _cartService.syncRemoveItem(productId);
    } catch (e) {
      debugPrint('Error syncing cart removal: $e');
    }
  }

  Future<void> updateStatusCheckOut (Bool status) async {
    _cartService.updateStatusCheckOut(status);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<void> loadCart() async {
    try {
      debugPrint('--- Starting loadCart ---');
      final remoteItems = await _cartService.fetchCartItems();
      _items.clear();

      for (var row in remoteItems) {
        final productData = row['products'];
        final product = Product.fromMap(productData);
        final quantity = row['quantity'] as int;

        _items[product.id] = CartItem(product: product, quantity: quantity);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
}