import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'pages/home_page.dart';
import 'pages/wishlist_screen.dart';
import 'pages/cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // ✅ List screens dengan PageStorageKey untuk preserve state
  final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey('home')),
    const WishlistScreen(key: PageStorageKey('wishlist')),
    const CartScreen(key: PageStorageKey('cart')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🎨 BOTTOM NAVIGATION BAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Tab - Index 0
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              
              // Wishlist Tab - Index 1 → WishlistScreen ✅
              _buildNavItem(1, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Wishlist'),
              
              // Cart Tab - Index 2 → CartScreen ✅
              _buildNavItem(2, Icons.shopping_cart_rounded, Icons.shopping_cart_outlined, 'Keranjang', isCart: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconFilled, IconData iconOutlined, String label, {bool isCart = false}) {
    final isSelected = _currentIndex == index;
    final cartCount = isCart ? _getCartCount() : 0;
    final wishlistCount = index == 1 ? _getWishlistCount() : 0;
    
    return GestureDetector(
      onTap: () {
        // ✅ FIX: Pindah ke screen yang sesuai dengan index
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor?.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // ✅ Icon berubah saat selected
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? iconFilled : iconOutlined,
                    key: ValueKey(isSelected),
                    size: 24,
                    color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey[500],
                  ),
                ),
                // ✅ Cart Badge - muncul jika ada item di cart
                if (isCart && cartCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: _buildBadge(cartCount),
                  ),
                // ✅ Wishlist Badge - muncul jika ada item di wishlist
                if (index == 1 && wishlistCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: _buildBadge(wishlistCount),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Label text
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ✅ Get cart count from CartService
  int _getCartCount() {
    try {
      return CartService.getTotalItems();
    } catch (e) {
      return 0;
    }
  }

  // ✅ Get wishlist count from WishlistService
  int _getWishlistCount() {
    try {
      return WishlistService.getWishlistCount();
    } catch (e) {
      return 0;
    }
  }
}