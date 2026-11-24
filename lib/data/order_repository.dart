import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/supabase_service.dart';

class OrderRepository {
  Future<String> placeOrder({
    required String address,
    required List<CartItem> items,
  }) async {
    final payload = items
        .map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            })
        .toList();

    final result = await SupabaseService.client.rpc(
      'place_order',
      params: {
        'p_delivery_address': address,
        'p_items': payload,
      },
    );
    return result as String;
  }

  Future<List<Order>> getMyOrders() async {
    final rows = await SupabaseService.client
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) => Order.fromMap(row)).toList();
  }
}
