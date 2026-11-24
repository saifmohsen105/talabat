import 'package:flutter/foundation.dart';

import '../data/order_repository.dart';
import '../models/cart_item.dart';

class OrdersController extends ChangeNotifier {
  OrdersController(this._repository);

  final OrderRepository _repository;
  bool isLoading = false;
  String? errorMessage;
  String? lastOrderId;

  Future<String?> placeOrder(String address, List<CartItem> items) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      lastOrderId = await _repository.placeOrder(address: address, items: items);
      return lastOrderId;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
