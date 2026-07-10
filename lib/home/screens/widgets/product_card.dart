import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../../../wishlist/controllers/wishlist_controller.dart';
import '../../../../cart/controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();
    final CartController cartController =
        Get.find<CartController>();
    return GestureDetector(
      onTap: () {
        // Navigate to details screen, passing the ID
        Get.toNamed('/product-details', arguments: product.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(20, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(40, 140, 110, 255),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image & Wishlist Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color.fromARGB(50, 140, 110, 255),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() {
                    final isWish = wishlistController.isWishlisted(product.id);
                    return GestureDetector(
                      onTap: () => wishlistController.toggleWishlist(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(150, 19, 5, 56),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWish ? Icons.favorite : Icons.favorite_border,
                          color: isWish ? Colors.redAccent : Colors.white,
                          size: 18,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFC7B6FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   // Add to Cart / Quantity Stepper
                  Obx(() {
                    final int cartQty = cartController.getProductQuantity(product.id);
                    if (cartQty > 0) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => cartController.updateQuantity(product.id, -1),
                          ),
                          Text(
                            '$cartQty',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => cartController.updateQuantity(product.id, 1),
                          ),
                        ],
                      );
                    } else {
                      return SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => cartController.addToCart(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8C6EFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
