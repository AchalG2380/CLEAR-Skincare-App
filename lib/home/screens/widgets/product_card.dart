import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to details screen, passing the ID
        Get.toNamed('/product-details', arguments: product.id);
      },
      child: Container(
        width: 155,
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color.fromARGB(50, 140, 110, 255),
                        child: const Icon(Icons.broken_image_outlined, color: Colors.white30),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(
                    () => GestureDetector(
                      onTap: () {
                        product.isWishlisted.toggle();
                        Get.snackbar(
                          product.isWishlisted.value ? 'Wishlisted' : 'Removed',
                          product.isWishlisted.value
                              ? '${product.name} added to Wishlist'
                              : '${product.name} removed from Wishlist',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color.fromARGB(240, 19, 5, 56),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 1),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(150, 19, 5, 56),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.isWishlisted.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isWishlisted.value
                              ? Colors.redAccent
                              : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
