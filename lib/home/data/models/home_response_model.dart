import 'product_model.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String? productActionId;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.productActionId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      productActionId: json['productActionId'],
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class ConcernModel {
  final String id;
  final String name;
  final String imageUrl;

  ConcernModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ConcernModel.fromJson(Map<String, dynamic> json) {
    return ConcernModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class HomeResponseModel {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> bestSellers;
  final List<ProductModel> newArrivals;
  final List<ConcernModel> skinConcerns;

  HomeResponseModel({
    required this.banners,
    required this.categories,
    required this.bestSellers,
    required this.newArrivals,
    required this.skinConcerns,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeResponseModel(
      banners: (json['banners'] as List? ?? [])
          .map((e) => BannerModel.fromJson(e))
          .toList(),
      categories: (json['categories'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      bestSellers: (json['bestSellers'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e))
          .toList(),
      newArrivals: (json['newArrivals'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e))
          .toList(),
      skinConcerns: (json['skinConcerns'] as List? ?? [])
          .map((e) => ConcernModel.fromJson(e))
          .toList(),
    );
  }
}
