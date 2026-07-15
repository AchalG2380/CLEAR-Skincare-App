import 'package:get/get.dart';

class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final RxBool isWishlisted;
  final String category; // e.g. 'cat_cleanser'
  final String concern; // e.g. 'Acne & Blemishes'

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required bool isWishlisted,
    this.category = '',
    this.concern = '',
  }) : isWishlisted = isWishlisted.obs;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // category comes back as a populated object ({_id, name, ...}) or plain string —
    // handle both so this works whether populate() is used or not
    String categoryValue = '';
    if (json['category'] is Map) {
      categoryValue = json['category']['_id'] ?? json['category']['name'] ?? '';
    } else if (json['category'] is String) {
      categoryValue = json['category'];
    }

    // images comes back as an array; ProductCard needs one imageUrl
    String firstImage = '';
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      firstImage = json['images'][0];
    } else if (json['imageUrl'] != null) {
      firstImage = json['imageUrl']; // fallback for mock data shape
    }

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: firstImage,
      price: (json['price'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      isWishlisted: json['isWishlisted'] ?? false,
      category: categoryValue,
      concern: json['concern'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'price': price,
    'rating': rating,
    'isWishlisted': isWishlisted.value,
    'category': category,
    'concern': concern,
  };
}
