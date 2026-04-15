import '../models/product.dart';

class WishlistService {
  static final List<Product> _wishlistProducts = [];

  // ✅ FIX: Return mutable copy agar bisa dimodifikasi di UI
  static List<Product> getWishlist() {
    return List<Product>.from(_wishlistProducts);
  }

  static void addToWishlist(Product product) {
    if (!_wishlistProducts.any((p) => p.id == product.id)) {
      _wishlistProducts.add(product);
    }
  }

  static void removeFromWishlist(Product product) {
    _wishlistProducts.removeWhere((p) => p.id == product.id);
  }

  static bool toggleWishlist(Product product) {
    if (_wishlistProducts.any((p) => p.id == product.id)) {
      removeFromWishlist(product);
      return false; // Removed
    } else {
      addToWishlist(product);
      return true; // Added
    }
  }

  static bool isInWishlist(Product product) {
    return _wishlistProducts.any((p) => p.id == product.id);
  }

  static int getWishlistCount() {
    return _wishlistProducts.length;
  }

  static void clearWishlist() {
    _wishlistProducts.clear();
  }
}