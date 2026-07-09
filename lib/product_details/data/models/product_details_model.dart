import '../../../home/data/models/product_model.dart';

class ReviewModel {
  final String reviewerName;
  final double rating;
  final String date;
  final String comment;

  ReviewModel({
    required this.reviewerName,
    required this.rating,
    required this.date,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewerName: json['reviewerName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      date: json['date'] ?? '',
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewerName': reviewerName,
      'rating': rating,
      'date': date,
      'comment': comment,
    };
  }
}

class ProductDetailsModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final List<String> imageUrls;
  final String ingredients;
  final List<String> benefits;
  final String usage;
  final List<ReviewModel> reviews;

  ProductDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrls,
    required this.ingredients,
    required this.benefits,
    required this.usage,
    required this.reviews,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    var imgs = (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    var bens = (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    var revs = (json['reviews'] as List<dynamic>?)?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    
    return ProductDetailsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrls: imgs,
      ingredients: json['ingredients'] ?? '',
      benefits: bens,
      usage: json['usage'] ?? '',
      reviews: revs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'imageUrls': imageUrls,
      'ingredients': ingredients,
      'benefits': benefits,
      'usage': usage,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: id,
      name: name,
      imageUrl: imageUrls.isNotEmpty ? imageUrls.first : '',
      price: price,
      rating: rating,
      isWishlisted: false, // Reads dynamically from WishlistController.isWishlisted(id) anyway
    );
  }
}
