class Order {
  final String id;
  final List<OrderItem> items;
  final double subtotal;  // ✅ double, bukan int
  final double shippingCost;  // ✅ double
  final double total;  // ✅ double
  final String address;
  final String paymentMethod;
  final DateTime orderDate;
  OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.orderDate,
    this.status = OrderStatus.pending,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;  // ✅ double
  final int quantity;  // ✅ int
  final String? variant;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.variant,
  });

  double get subtotal => price * quantity;  // ✅ Return double
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}