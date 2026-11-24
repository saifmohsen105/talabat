import '../models/category.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

class ProductRepository {
  Future<List<Category>> getCategories() async {
    final rows = await SupabaseService.client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return rows.map((row) => Category.fromMap(row)).toList();
  }

  Future<List<Product>> getProducts() async {
    final rows = await SupabaseService.client
        .from('products')
        .select()
        .eq('is_active', true)
        .order('name');
    return rows.map((row) => Product.fromMap(row)).toList();
  }
}
