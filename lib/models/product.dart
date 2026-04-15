class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  
  // ✅ Field tambahan untuk fitur modern (opsional, bisa null)
  final String? category;
  final double? rating;
  final int? reviewCount;
  final double? discount; // dalam persen, misal: 20 untuk 20%
  final double? originalPrice;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.category,
    this.rating,
    this.reviewCount,
    this.discount,
    this.originalPrice,
  });

  // ✅ Factory dari JSON (sesuaikan dengan API Anda)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      category: json['category'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      discount: json['discount']?.toDouble(),
      originalPrice: json['original_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'rating': rating,
      'review_count': reviewCount,
      'discount': discount,
      'original_price': originalPrice,
    };
  }
}