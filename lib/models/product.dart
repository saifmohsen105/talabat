class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFeatured = false,
    this.isPopular = false,
  });

  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String description;
  final double price;
  final String imageUrl;
  final bool isFeatured;
  final bool isPopular;

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        categoryId: map['category_id'] as String,
        name: map['name'] as String,
        slug: map['slug'] as String,
        description: (map['description'] as String?) ?? '',
        price: (map['price'] as num).toDouble(),
        imageUrl: map['image_url'] as String,
        isFeatured: map['is_featured'] as bool? ?? false,
        isPopular: map['is_popular'] as bool? ?? false,
      );
}
