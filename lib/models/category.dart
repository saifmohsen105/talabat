class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String? imageUrl;

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        slug: map['slug'] as String,
        imageUrl: map['image_url'] as String?,
      );
}
