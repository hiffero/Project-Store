import '../models/order.dart';

class OrderService {
  static final List<Order> _orders = [];

  static String generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<Order> createOrder({
    required List<OrderItem> items,
    required String address,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // ✅ Gunakan double untuk perhitungan harga
    final double subtotal = items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    
    final double shippingCost = subtotal > 100000 ? 0 : 15000;
    final double total = subtotal + shippingCost;

    final order = Order(
      id: generateOrderId(),
      items: items,
      subtotal: subtotal,
      shippingCost: shippingCost,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      orderDate: DateTime.now(),
    );

    _orders.add(order);
    return order;
  }

  static List<Order> getOrders() {
    return List.unmodifiable(_orders);
  }

  // ✅ FIX: Gunakan try-catch untuk handle null return
  static Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } on StateError {
      return null;
    }
  }

  static void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = Order(
        id: _orders[index].id,
        items: _orders[index].items,
        subtotal: _orders[index].subtotal,
        shippingCost: _orders[index].shippingCost,
        total: _orders[index].total,
        address: _orders[index].address,
        paymentMethod: _orders[index].paymentMethod,
        orderDate: _orders[index].orderDate,
        status: status,
      );
    }
  }
}