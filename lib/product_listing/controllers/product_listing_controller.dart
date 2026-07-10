import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/base_controller.dart';
import '../../home/data/models/product_model.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../data/repositories/product_listing_repository.dart';

class ProductListingController extends BaseSkincareController {
  final ProductListingRepository _repo = ProductListingRepository();

  // --- UI Controllers ---
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // --- Observable state ---
  final products = <ProductModel>[].obs;
  var isLoadingMore = false.obs;
  final hasMore = true.obs;

  // --- Filter / Sort (Rx for reactive AppBar title & filter badge) ---
  var selectedSort = ''.obs;
  var selectedCategory = ''.obs;
  var selectedConcern = ''.obs;

  // --- Internal ---
  String _searchQuery = '';
  Timer? _debounce;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill filters from navigation arguments (Home categories / concerns)
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedCategory.value = (args['category'] as String?) ?? '';
      selectedConcern.value = (args['concern'] as String?) ?? '';
    }
    scrollController.addListener(_onScroll);
    fetchProducts();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // --- Scroll Listener ---
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadNextPage();
    }
  }

  // --- Search (debounced 500ms) ---
  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query.trim();
      fetchProducts();
    });
  }

  // --- Sort ---
  void onSortSelected(String sort) {
    selectedSort.value = sort;
    fetchProducts();
  }

  // --- Filter ---
  void onFilterApplied({required String category, required String concern}) {
    selectedCategory.value = category;
    selectedConcern.value = concern;
    fetchProducts();
  }

  // --- Main fetch (always resets to page 1) ---
  Future<void> fetchProducts() async {
    _currentPage = 1;
    products.clear();
    hasMore.value = true;

    final result = await runSafeApiCall(() async {
      return _repo.getProducts(
        page: 1,
        limit: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        sort: selectedSort.value.isEmpty ? null : selectedSort.value,
        category: selectedCategory.value.isEmpty
            ? null
            : selectedCategory.value,
        concern: selectedConcern.value.isEmpty ? null : selectedConcern.value,
      );
    });

    if (result != null) {
      products.assignAll(result.products);

      // Sync with global WishlistController
      final wishlistController = Get.find<WishlistController>();
      for (var p in result.products) {
        if (p.isWishlisted.value) {
          wishlistController.wishlistedIds.add(p.id);
        }
      }

      hasMore.value = result.hasMore;
      _currentPage = 2;
    }
  }

  // --- Load next page (called by scroll listener) ---
  Future<void> loadNextPage() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      final result = await _repo.getProducts(
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        sort: selectedSort.value.isEmpty ? null : selectedSort.value,
        category: selectedCategory.value.isEmpty
            ? null
            : selectedCategory.value,
        concern: selectedConcern.value.isEmpty ? null : selectedConcern.value,
      );
      products.addAll(result.products);

      // Sync with global WishlistController
      final wishlistController = Get.find<WishlistController>();
      for (var p in result.products) {
        if (p.isWishlisted.value) {
          wishlistController.wishlistedIds.add(p.id);
        }
      }

      hasMore.value = result.hasMore;
      _currentPage++;
    } catch (_) {
      // Silently fail — user can scroll to retry via pull-to-refresh
    } finally {
      isLoadingMore.value = false;
    }
  }

  // --- Pull-to-refresh ---
  @override
  Future<void> refresh() => fetchProducts();

  // --- Helpers for UI ---
  bool get hasActiveFilter =>
      selectedCategory.value.isNotEmpty || selectedConcern.value.isNotEmpty;

  String get activeTitle {
    if (selectedCategory.value.isNotEmpty) {
      return _categoryLabel(selectedCategory.value);
    }
    if (selectedConcern.value.isNotEmpty) return selectedConcern.value;
    return 'Products';
  }

  String _categoryLabel(String id) {
    const labels = {
      'cat_cleanser': 'Cleansers',
      'cat_moisturizer': 'Moisturizers',
      'cat_serum': 'Serums',
      'cat_sunscreen': 'Sunscreens',
    };
    return labels[id] ?? 'Products';
  }
}
