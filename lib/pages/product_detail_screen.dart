import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'cart_screen.dart'; // ✅ FIX: Import CartScreen

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  bool _isInWishlist = false;
  int _selectedTab = 0;
  late PageController _imagePageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _availableSizes = ['S', 'M', 'L', 'XL'];
  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Hitam', 'code': '#1a1a1a'},
    {'name': 'Putih', 'code': '#ffffff'},
    {'name': 'Navy', 'code': '#1e3a5f'},
    {'name': 'Abu', 'code': '#808080'},
  ];

  final List<Map<String, dynamic>> _reviews = [
    {
      'user': 'Andi S.',
      'rating': 5,
      'comment': 'Kualitas bagus, sesuai ekspektasi! Pengiriman cepat 👍',
      'date': '2 hari lalu',
      'image': 'https://i.pravatar.cc/40?img=1',
    },
    {
      'user': 'Siti R.',
      'rating': 4,
      'comment': 'Bahan nyaman, tapi ukuran agak kecil. Size up recommended.',
      'date': '5 hari lalu',
      'image': 'https://i.pravatar.cc/40?img=5',
    },
    {
      'user': 'Budi W.',
      'rating': 5,
      'comment': 'Worth it! Sudah order 3x, nggak pernah kecewa.',
      'date': '1 minggu lalu',
      'image': 'https://i.pravatar.cc/40?img=8',
    },
  ];

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController(viewportFraction: 0.9);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _checkWishlist();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _checkWishlist() {
    setState(() {
      _isInWishlist = WishlistService.isInWishlist(widget.product);
    });
  }

  String _formatRupiah(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // ✅ FIX: Tambahkan parameter untuk navigasi ke CartScreen
  void _addToCart({bool navigateToCart = false}) {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Pilih ukuran terlebih dahulu'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    for (int i = 0; i < _quantity; i++) {
      CartService.addToCart(widget.product);
    }

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_quantity x ${widget.product.name} berhasil ditambahkan',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        // ✅ FIX: Tambahkan action untuk navigasi ke cart
        action: SnackBarAction(
          label: 'Lihat Keranjang',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );

    // ✅ FIX: Jika navigateToCart true, langsung ke CartScreen
    if (navigateToCart) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        }
      });
    }
  }

  void _toggleWishlist() {
    setState(() {
      _isInWishlist = WishlistService.toggleWishlist(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildImageCarousel()),
              SliverToBoxAdapter(child: _buildProductContent()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🎯 APP BAR - GLASSMORPHISM STYLE
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isInWishlist ? Colors.redAccent : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isInWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(_isInWishlist),
                size: 20,
                color: _isInWishlist ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: _toggleWishlist,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🖼️ IMAGE CAROUSEL - MODERN DESIGN
  // ─────────────────────────────────────────────────────────────
  Widget _buildImageCarousel() {
    return Container(
      height: 450,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            itemCount: 4,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Hero(
                    tag: 'product_${widget.product.id}_$index',
                    child: Image.network(
                      "http://192.168.9.57:3000${widget.product.image}",
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_rounded, size: 60),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Dots Indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentImageIndex == index 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 📦 PRODUCT CONTENT
  // ─────────────────────────────────────────────────────────────
  Widget _buildProductContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            const SizedBox(height: 24),
            _buildPriceSection(),
            const SizedBox(height: 24),
            _buildVariantSection(),
            const SizedBox(height: 24),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 📋 PRODUCT HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '4.5',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber[800]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '(2.4rb terjual)',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Stok tersedia',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 💰 PRICE SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product.price > 100000)
                Text(
                  _formatRupiah(widget.product.price * 1.2),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                _formatRupiah(widget.product.price),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (widget.product.price > 100000)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'HEMAT 20%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🎨 VARIANT SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildVariantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ukuran',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableSizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Warna',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _availableColors.map((color) {
            final isSelected = _selectedColor == color['name'];
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color['name']),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isSelected ? 3 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color['code'].replaceAll('#', '0xff'))),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      color['name'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.black87 : Colors.grey[500],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 📑 INFO SECTION (Tabs)
  // ─────────────────────────────────────────────────────────────
  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildTabButton(0, 'Deskripsi'),
              _buildTabButton(1, 'Ulasan'),
              _buildTabButton(2, 'Spesifikasi'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selectedTab == 0 
            ? _buildDescription() 
            : _selectedTab == 1 
              ? _buildReviews() 
              : _buildSpecs(),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          ...['✓ Bahan premium berkualitas tinggi', '✓ Jahitan rapi dan kuat', '✓ Nyaman dipakai seharian']
              .map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: Colors.teal[600]),
                        const SizedBox(width: 8),
                        Text(feature, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('4.5', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.grey[800])),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 14, color: Colors.amber[500]))),
                  Text('${_reviews.length} ulasan', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._reviews.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(review['image']), radius: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review['user'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(review['comment'], style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSpecs() {
    final specs = [
      {'label': 'Berat', 'value': '500 gram'},
      {'label': 'Material', 'value': 'Premium'},
      {'label': 'Asal', 'value': 'Indonesia'},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: specs
            .map((spec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 80, child: Text(spec['label']!, style: TextStyle(color: Colors.grey[500]))),
                      Text(':', style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(width: 8),
                      Text(spec['value']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🛒 BOTTOM BAR - ✅ FIXED: NAVIGATE TO CART
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Jumlah:', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_rounded, size: 18),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_rounded, size: 18),
                          onPressed: () => setState(() => _quantity++),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatRupiah(widget.product.price * _quantity),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _addToCart(navigateToCart: true), // ✅ FIX: Navigate to cart after add
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Tambah ke Keranjang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}