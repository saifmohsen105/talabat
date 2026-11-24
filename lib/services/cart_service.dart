import 'dart:async';
import 'dart:ffi';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final _supabase = Supabase.instance.client;

  Future<String?> fetchCartId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final existingCart = await _supabase
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .eq("is_checkout", false)
        .maybeSingle();

    return existingCart?['id'] as String?;
  }

  Future<List> fetchCartItems() async {
    try {
      final cartId = await fetchCartId();
      if (cartId == null) return [];

      final items = await _supabase
          .from('cart_items')
          .select('quantity, product_id, products(*)')
          .eq('cart_id', cartId) ;

      return List.from(items);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Future<String> createCart() async {
    final userId = _supabase.auth.currentUser!.id;

    final newCart = await _supabase
        .from('carts')
        .insert({'user_id': userId})
        .select('id')
        .single();

    return newCart['id'] as String;
  }

  Future<String> _getOrCreateCartId() async {
    String? cartId = await fetchCartId();
    if (cartId != null) {
      return cartId;
    }
    return await createCart();
  }

  Future<void> syncAddToCart(String productId, int quantity) async {
    try {
      final cartId = await _getOrCreateCartId();

      await _supabase.from('cart_items').upsert({
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantity,
      }, onConflict: 'cart_id, product_id');
    } catch (e) {
      throw Exception('Failed to sync cart with Supabase: $e');
    }
  }

  Future<void> updateStatusCheckOut(Bool status) async {
    try {
      final cartId = await _getOrCreateCartId();
      await _supabase
          .from('carts')
          .update({
        "is_checkout": status,
      })
          .eq('id', cartId);
    } catch (e) {
      throw Exception('Failed to sync cart with Supabase: $e');
    }
  }

  Future<void> syncRemoveItem(String productId) async {
    try {
      final cartId = await _getOrCreateCartId();
      await _supabase
          .from('cart_items')
          .delete()
          .eq('cart_id', cartId)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Failed to remove item from Supabase: $e');
    }
  }
}