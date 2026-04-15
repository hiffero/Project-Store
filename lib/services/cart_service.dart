// lib/services/cart_service.dart
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}

class CartService {
  static final List<CartItem> _cartItems = [];

  static void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
  }

  static List<CartItem> getCartItems() {
    return List.unmodifiable(_cartItems);
  }

  static int getTotalItems() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  static double getTotalPrice() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  static void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
  }

  static void increaseQty(Product product) {
    final item = _cartItems.firstWhere(
      (i) => i.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    if (item.quantity > 0) {
      item.quantity++;
    }
  }

  static void decreaseQty(Product product) {
    final item = _cartItems.firstWhere(
      (i) => i.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      removeFromCart(product);
    }
  }

  static void clearCart() {
    _cartItems.clear();
  }
}