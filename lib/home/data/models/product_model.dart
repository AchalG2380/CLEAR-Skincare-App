import 'package:get/get.dart';

class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final RxBool isWishlisted;
  final String category; // e.g. 'cat_cleanser'
  final String concern;  // e.g. 'Acne & Blemishes'

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
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      isWishlisted: json['isWishlisted'] ?? false,
      category: json['category'] ?? '',
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
