class Order {
  const Order({
    required this.id,
    required this.status,
    required this.total,
    required this.address,
    required this.createdAt,
  });

  final String id;
  final String status;
  final double total;
  final String address;
  final DateTime createdAt;

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['id'] as String,
        status: map['status'] as String,
        total: (map['total'] as num).toDouble(),
        address: map['delivery_address'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
