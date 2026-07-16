import '../../../home/data/models/product_model.dart';

class CartItemModel {
  final String cartItemId;
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.cartItemId,
    required this.product,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['_id'] ?? '',
      product: json['product'] is Map
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : ProductModel(
              id: json['product'] as String? ?? '',
              name: '',
              imageUrl: '',
              price: 0.0,
              rating: 0.0,
              isWishlisted: false,
              category: '',
              concern: '',
            ),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }
}
