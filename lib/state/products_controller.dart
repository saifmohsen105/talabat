import 'package:flutter/foundation.dart';

import '../data/product_repository.dart';
import '../models/category.dart' as model;
import '../models/product.dart';

class ProductsController extends ChangeNotifier {
  ProductsController(this._repository);

  final ProductRepository _repository;
  List<model.Category> categories = [];
  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getProducts(),
      ]);
      categories = (results[0] as List).cast<model.Category>();
      products = (results[1] as List).cast<Product>();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Product? findProduct(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<Product> filtered({
    String query = '',
    String? categoryId,
  }) {
    final normalized = query.trim().toLowerCase();
    return products.where((product) {
      final matchesQuery = normalized.isEmpty ||
          product.name.toLowerCase().contains(normalized) ||
          product.description.toLowerCase().contains(normalized);
      final matchesCategory =
          categoryId == null || product.categoryId == categoryId;
      return matchesQuery && matchesCategory;
    }).toList();
  }
}