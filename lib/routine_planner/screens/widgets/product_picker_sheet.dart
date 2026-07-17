import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_theme.dart';
import '../../../home/data/models/product_model.dart';
import '../../../wishlist/controllers/wishlist_controller.dart';
import '../../../cart/controllers/cart_controller.dart';
import '../../../product_listing/data/repositories/product_listing_repository.dart';
import '../../../core/widgets/app_widgets.dart';

class ProductPickerSheet extends StatefulWidget {
  final String stepName;

  const ProductPickerSheet({super.key, required this.stepName});

  @override
  State<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<ProductPickerSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ProductListingRepository _repo = ProductListingRepository();
  late TabController _tabController;

  final WishlistController _wishlistController = Get.find<WishlistController>();
  final CartController _cartController = Get.find<CartController>();

  // Search tab state
  final RxList<ProductModel> _searchResults = <ProductModel>[].obs;
  final RxBool _isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Pre-populate search query with the step name to fetch relevant products
    _searchController.text = widget.stepName;
    _performSearch(widget.stepName);

    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      return;
    }

    try {
      _isSearching.value = true;
      final result = await _repo.getProducts(
        page: 1,
        limit: 15,
        search: query,
      );
      _searchResults.assignAll(result.products);
    } catch (_) {
      _searchResults.clear();
    } finally {
      _isSearching.value = false;
    }
  }

  List<ProductModel> _filterLocalList(List<ProductModel> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select ${widget.stepName}',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: AppTheme.primaryText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppTheme.textMuted, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            tabs: const [
              Tab(text: 'Favorites'),
              Tab(text: 'Cart'),
              Tab(text: 'Search All'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Favorites Tab
                Obx(() {
                  final filtered = _filterLocalList(
                    _wishlistController.wishlistItems,
                    _searchController.text,
                  );
                  if (filtered.isEmpty) {
                    return _buildEmptyTabState(
                      icon: Icons.favorite_border,
                      msg: 'No matching favorites found',
                    );
                  }
                  return _buildProductList(filtered);
                }),

                // 2. Cart Tab
                Obx(() {
                  final cartProducts = _cartController.cartItems.map((e) => e.product).toList();
                  final filtered = _filterLocalList(
                    cartProducts,
                    _searchController.text,
                  );
                  if (filtered.isEmpty) {
                    return _buildEmptyTabState(
                      icon: Icons.shopping_bag_outlined,
                      msg: 'No matching cart items found',
                    );
                  }
                  return _buildProductList(filtered);
                }),

                // 3. Search All Tab
                Obx(() {
                  if (_isSearching.value) {
                    return Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  if (_searchResults.isEmpty) {
                    return _buildEmptyTabState(
                      icon: Icons.search_off,
                      msg: 'No products found',
                    );
                  }
                  return _buildProductList(_searchResults);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: products.length,
      separatorBuilder: (_, __) => Divider(color: AppTheme.dividerColor, height: 24),
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () => Get.back(result: product),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 54,
                  height: 54,
                  color: Colors.white, // blend white images
                  child: getSkincareImage(
                    product.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.ratingStar, size: 13),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyTabState({required IconData icon, required String msg}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textHint, size: 48),
          const SizedBox(height: 12),
          Text(
            msg,
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
