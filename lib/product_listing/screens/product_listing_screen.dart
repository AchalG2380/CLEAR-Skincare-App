import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/product_widgets.dart';
import '../../core/widgets/app_widgets.dart';
import '../controllers/product_listing_controller.dart';

class ProductListingScreen extends StatelessWidget {
  ProductListingScreen({super.key});

  final ProductListingController controller = Get.put(
    ProductListingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) return _buildShimmer();
                  if (controller.hasError.value) return _buildError();
                  if (controller.products.isEmpty) return _buildEmpty();
                  return _buildGrid(
                    products: controller.products,
                    isLoadingMore: controller.isLoadingMore.value,
                    hasMore: controller.hasMore.value,
                  );
                }),
              ),
            ],
          ),
          const Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SkincareCompareFloatingBar(),
          ),
        ],
      ),
    ));
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Text(
          controller.activeTitle,
          style: TextStyle(
            color: AppTheme.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        // Sort button
        Obx(
          () => IconButton(
            icon: Icon(
              Icons.sort,
              color: controller.selectedSort.value.isNotEmpty
                  ? AppTheme.primary
                  : Colors.white70,
            ),
            tooltip: AppStrings.tooltipSort,
            onPressed: () => _showSortSheet(context),
          ),
        ),
        // Filter button with active badge
        Obx(
          () => Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune,
                  color: controller.hasActiveFilter
                      ? AppTheme.primary
                      : AppTheme.secondaryText,
                ),
                tooltip: AppStrings.tooltipFilter,
                onPressed: () => _showFilterSheet(context),
              ),
              if (controller.hasActiveFilter)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Search Bar ─────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: TextStyle(color: AppTheme.primaryText),
        cursorColor: AppTheme.primary,
        decoration: InputDecoration(
          hintText: AppStrings.searchIngredientsHint,
          hintStyle: TextStyle(color: AppTheme.textDark),
          prefixIcon: Icon(Icons.search, color: AppTheme.textDark),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textDark,
                      size: 18,
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.onSearchChanged('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: AppTheme.inputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primary.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid({
    required List products,
    required bool isLoadingMore,
    required bool hasMore,
  }) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppTheme.primary,
      backgroundColor: AppTheme.backgroundColor,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.67,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => ProductCard(product: controller.products[i]),
                childCount: controller.products.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (_) {
                if (isLoadingMore) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                if (!hasMore && controller.products.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'You\'ve seen everything ✨',
                        style: TextStyle(color: AppTheme.textHint, fontSize: 13),
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 24);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Loading / Error / Empty States ────────────────────────────────────
  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.67,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _ProductCardSkeleton(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 60),
            const SizedBox(height: 16),
            Text(
              AppStrings.productsLoadError,
              style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textDark, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.fetchProducts,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                AppStrings.retry,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: AppTheme.textHint, size: 70),
          const SizedBox(height: 16),
          Text(
            AppStrings.noProductsFound,
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.adjustSearchFilters,
            style: TextStyle(color: AppTheme.textDark, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              controller.searchController.clear();
              controller.onFilterApplied(category: '', concern: '');
              controller.onSortSelected('');
            },
            child: Text(
              AppStrings.clearAllFilters,
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sort Bottom Sheet ──────────────────────────────────────────────────
  void _showSortSheet(BuildContext context) {
    final options = [
      ('', AppStrings.sortDefault),
      ('price_asc', AppStrings.sortPriceLowToHigh),
      ('price_desc', AppStrings.sortPriceHighToLow),
      ('top_rated', AppStrings.sortTopRated),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                AppStrings.sortBy,
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...options.map((opt) {
              final isActive = controller.selectedSort.value == opt.$1;
              return ListTile(
                leading: Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isActive ? AppTheme.primary : AppTheme.textDark,
                  size: 20,
                ),
                title: Text(
                  opt.$2,
                  style: TextStyle(
                    color: isActive ? AppTheme.primary : AppTheme.primaryText,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  controller.onSortSelected(opt.$1);
                  Get.back();
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Filter Bottom Sheet ────────────────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    String tempCategory = controller.selectedCategory.value;
    String tempConcern = controller.selectedConcern.value;

    final categories = [
      ('', 'All Categories'),
      ('cat_cleanser', 'Cleanser'),
      ('cat_moisturizer', 'Moisturizer'),
      ('cat_serum', 'Serum'),
      ('cat_sunscreen', 'Sunscreen'),
    ];

    final concerns = [
      ('', 'All Concerns'),
      ('Acne & Blemishes', 'Acne & Blemishes'),
      ('Dry & Flaky Skin', 'Dry & Flaky Skin'),
      ('Dark Spots', 'Dark Spots'),
      ('Anti-Aging', 'Anti-Aging'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, scrollCtrl) => Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      AppStrings.filterProductsTitle,
                      style: TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Category
                    _filterSectionHeader(AppStrings.filterCategory),
                    ...categories.map((cat) {
                      final isSelected = tempCategory == cat.$1;
                      return _filterOption(
                        label: cat.$2,
                        isSelected: isSelected,
                        onTap: () => setModalState(() => tempCategory = cat.$1),
                      );
                    }),

                    const SizedBox(height: 8),

                    // Skin Concern
                    _filterSectionHeader(AppStrings.filterConcern),
                    ...concerns.map((con) {
                      final isSelected = tempConcern == con.$1;
                      return _filterOption(
                        label: con.$2,
                        isSelected: isSelected,
                        onTap: () => setModalState(() => tempConcern = con.$1),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            tempCategory = '';
                            tempConcern = '';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textMuted,
                          side: BorderSide(color: AppTheme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(AppStrings.clear),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.onFilterApplied(
                            category: tempCategory,
                            concern: tempConcern,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          AppStrings.applyFilters,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(
      title,
      style: TextStyle(
        color: AppTheme.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    ),
  );

  Widget _filterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withValues(alpha: 0.20)
            : AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AppTheme.primary
              : AppTheme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? AppTheme.primary : AppTheme.textDark,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText),
          ),
        ],
      ),
    ),
  );
}

// ─── Skeleton shimmer card ──────────────────────────────────────────────────
class _ProductCardSkeleton extends StatefulWidget {
  @override
  State<_ProductCardSkeleton> createState() => _ProductCardSkeletonState();
}

class _ProductCardSkeletonState extends State<_ProductCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.1, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
