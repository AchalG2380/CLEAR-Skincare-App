import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/controllers/comparison_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../product_details/data/models/product_details_model.dart';
import '../../product_details/data/repositories/product_details_repository.dart';

class ComparisonScreenController extends GetxController {
  final ComparisonController comparisonController = Get.find<ComparisonController>();
  final ProductDetailsRepository _detailsRepo = ProductDetailsRepository();

  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  final detailedProducts = <ProductDetailsModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch details when screen loads
    loadDetails();
    
    // Listen to changes in compared items list to re-fetch
    ever(comparisonController.comparedIds, (_) => loadDetails());
  }

  Future<void> loadDetails() async {
    final ids = comparisonController.comparedIds;
    if (ids.length < 2) {
      detailedProducts.clear();
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;

      // Fetch all details in parallel using Future.wait
      final results = await Future.wait(
        ids.map((id) => _detailsRepo.getProductDetails(id)),
      );

      detailedProducts.assignAll(results);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComparisonScreenController());
    final comparisonController = Get.find<ComparisonController>();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Compare Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            if (comparisonController.comparedIds.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () => comparisonController.clearComparison(),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final count = comparisonController.comparedIds.length;

        // 1. Insufficient products state
        if (count < 2) {
          return SkincareEmptyState(
            icon: Icons.balance,
            title: 'Add products to compare',
            description: 'Select at least 2 products to compare their attributes side-by-side.',
            buttonText: 'Browse Products',
            onButtonPressed: () {
              if (Get.previousRoute.isNotEmpty) {
                Get.back();
              } else {
                Get.offNamed('/product-listing');
              }
            },
          );
        }

        // 2. Loading state
        if (controller.isLoading.value) {
          return _buildShimmerLoading(count);
        }

        // 3. Error state
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColor.error, size: 50),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadDetails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // 4. Comparison table view
        final detailedProducts = controller.detailedProducts;
        final screenWidth = MediaQuery.of(context).size.width;
        final labelColumnWidth = 100.0;
        
        // Compute product column width dynamically: fill screen if 2 products, scroll if 3
        final productColumnWidth = count == 2 
            ? (screenWidth - labelColumnWidth) / 2
            : 140.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: labelColumnWidth + (productColumnWidth * detailedProducts.length),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildTableRow(
                    labelColumnWidth,
                    label: '',
                    cells: detailedProducts.asMap().entries.map((e) => _buildProductCell(
                      productColumnWidth,
                      child: _buildHeaderCell(e.value, comparisonController),
                      index: e.key,
                      count: detailedProducts.length,
                    )).toList(),
                  ),
                  _buildTableRow(
                    labelColumnWidth,
                    label: 'Price',
                    cells: detailedProducts.asMap().entries.map((e) => _buildProductCell(
                      productColumnWidth,
                      child: _buildPriceCell(e.value),
                      index: e.key,
                      count: detailedProducts.length,
                    )).toList(),
                  ),
                  _buildTableRow(
                    labelColumnWidth,
                    label: 'Rating',
                    cells: detailedProducts.asMap().entries.map((e) => _buildProductCell(
                      productColumnWidth,
                      child: _buildRatingCell(e.value),
                      index: e.key,
                      count: detailedProducts.length,
                    )).toList(),
                  ),
                  _buildTableRow(
                    labelColumnWidth,
                    label: 'Benefits',
                    cells: detailedProducts.asMap().entries.map((e) => _buildProductCell(
                      productColumnWidth,
                      child: _buildBenefitsCell(e.value),
                      index: e.key,
                      count: detailedProducts.length,
                    )).toList(),
                  ),
                  _buildTableRow(
                    labelColumnWidth,
                    label: 'Ingredients',
                    cells: detailedProducts.asMap().entries.map((e) => _buildProductCell(
                      productColumnWidth,
                      child: _buildIngredientsCell(e.value),
                      index: e.key,
                      count: detailedProducts.length,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTableRow(
    double labelWidth, {
    required String label,
    required List<Widget> cells,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Label Column
          Container(
            width: labelWidth,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: AppColor.surface.withValues(alpha: 0.4),
              border: Border(
                bottom: BorderSide(color: AppColor.dividerColor.withValues(alpha: 0.15)),
                right: BorderSide(color: AppColor.dividerColor.withValues(alpha: 0.15)),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColor.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          ...cells,
        ],
      ),
    );
  }

  Widget _buildProductCell(
    double width, {
    required Widget child,
    required int index,
    required int count,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.dividerColor.withValues(alpha: 0.15)),
          right: index < count - 1
              ? BorderSide(color: AppColor.dividerColor.withValues(alpha: 0.15))
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  Widget _buildHeaderCell(ProductDetailsModel product, ComparisonController comparisonController) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: getSkincareImage(
                  product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Positioned(
          top: -2,
          right: -2,
          child: GestureDetector(
            onTap: () => comparisonController.toggleCompare(product.id),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCell(ProductDetailsModel product) {
    return Center(
      child: Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildRatingCell(ProductDetailsModel product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: AppColor.ratingStar, size: 14),
        const SizedBox(width: 4),
        Text(
          '${product.rating}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsCell(ProductDetailsModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: product.benefits
          .map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: AppColor.primary, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildIngredientsCell(ProductDetailsModel product) {
    return Text(
      product.ingredients,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 10,
        height: 1.4,
      ),
    );
  }

  Widget _buildShimmerLoading(int count) {
    return Row(
      children: [
        Container(
          width: 100,
          color: AppColor.surface.withValues(alpha: 0.1),
        ),
        ...List.generate(count, (_) => Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            ),
          ),
        )),
      ],
    );
  }
}
