import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../home/data/models/product_model.dart';

class ProductListingResult {
  final List<ProductModel> products;
  final bool hasMore;
  const ProductListingResult({required this.products, required this.hasMore});
}

class ProductListingRepository {
  final String baseUrl = 'https://your-api-base-url.com/api';

  Future<ProductListingResult> getProducts({
    required int page,
    required int limit,
    String? search,
    String? sort,
    String? category,
    String? concern,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        if (category != null && category.isNotEmpty) 'category': category,
        if (concern != null && concern.isNotEmpty) 'concern': concern,
      };
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (data['products'] as List<dynamic>?) ?? [];
        final products = items.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
        final hasMore = (data['hasMore'] as bool?) ?? (products.length >= limit);
        return ProductListingResult(products: products, hasMore: hasMore);
      }
      throw Exception('Server returned ${response.statusCode}');
    } catch (_) {
      return _mockResult(page: page, limit: limit, search: search, sort: sort, category: category, concern: concern);
    }
  }

  ProductListingResult _mockResult({
    required int page,
    required int limit,
    String? search,
    String? sort,
    String? category,
    String? concern,
  }) {
    var all = List<ProductModel>.from(_catalogue);

    // Client-side filters
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      all = all.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    if (category != null && category.isNotEmpty) {
      all = all.where((p) => p.category == category).toList();
    }
    if (concern != null && concern.isNotEmpty) {
      all = all.where((p) => p.concern == concern).toList();
    }

    // Sort
    switch (sort) {
      case 'price_asc':
        all.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        all.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'top_rated':
        all.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    // Paginate
    final start = (page - 1) * limit;
    if (start >= all.length) return const ProductListingResult(products: [], hasMore: false);
    final end = (start + limit).clamp(0, all.length);
    return ProductListingResult(
      products: all.sublist(start, end),
      hasMore: end < all.length,
    );
  }

  // 20-item mock catalogue — 5 per category
  static final List<ProductModel> _catalogue = [
    // Cleansers
    ProductModel(id: 'c1', name: 'Gentle Foam Cleanser', imageUrl: 'https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?q=80&w=300&auto=format&fit=crop', price: 18.50, rating: 4.5, isWishlisted: false, category: 'cat_cleanser', concern: 'Acne & Blemishes'),
    ProductModel(id: 'c2', name: 'Micellar Cleansing Water', imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=300&auto=format&fit=crop', price: 14.00, rating: 4.3, isWishlisted: false, category: 'cat_cleanser', concern: 'Dry & Flaky Skin'),
    ProductModel(id: 'c3', name: 'Oil Control Face Wash', imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=300&auto=format&fit=crop', price: 16.00, rating: 4.6, isWishlisted: false, category: 'cat_cleanser', concern: 'Acne & Blemishes'),
    ProductModel(id: 'c4', name: 'Brightening Gel Cleanser', imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=300&auto=format&fit=crop', price: 21.00, rating: 4.4, isWishlisted: false, category: 'cat_cleanser', concern: 'Dark Spots'),
    ProductModel(id: 'c5', name: 'Anti-Age Cleansing Balm', imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=300&auto=format&fit=crop', price: 28.00, rating: 4.7, isWishlisted: false, category: 'cat_cleanser', concern: 'Anti-Aging'),

    // Moisturizers
    ProductModel(id: 'm1', name: 'Barrier Recovery Cream', imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=300&auto=format&fit=crop', price: 24.00, rating: 4.6, isWishlisted: false, category: 'cat_moisturizer', concern: 'Dry & Flaky Skin'),
    ProductModel(id: 'm2', name: 'Acne Control Gel Cream', imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=300&auto=format&fit=crop', price: 22.00, rating: 4.5, isWishlisted: false, category: 'cat_moisturizer', concern: 'Acne & Blemishes'),
    ProductModel(id: 'm3', name: 'Hyaluronic Day Cream', imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=300&auto=format&fit=crop', price: 30.00, rating: 4.8, isWishlisted: true, category: 'cat_moisturizer', concern: 'Dry & Flaky Skin'),
    ProductModel(id: 'm4', name: 'Brightening Moisturizer', imageUrl: 'https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?q=80&w=300&auto=format&fit=crop', price: 26.00, rating: 4.4, isWishlisted: false, category: 'cat_moisturizer', concern: 'Dark Spots'),
    ProductModel(id: 'm5', name: 'Retinol Night Cream', imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=300&auto=format&fit=crop', price: 38.00, rating: 4.9, isWishlisted: false, category: 'cat_moisturizer', concern: 'Anti-Aging'),

    // Serums
    ProductModel(id: 's1', name: 'Vitamin C Radiance Serum', imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=300&auto=format&fit=crop', price: 29.99, rating: 4.8, isWishlisted: true, category: 'cat_serum', concern: 'Dark Spots'),
    ProductModel(id: 's2', name: 'Niacinamide Pore Serum', imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=300&auto=format&fit=crop', price: 23.00, rating: 4.6, isWishlisted: false, category: 'cat_serum', concern: 'Acne & Blemishes'),
    ProductModel(id: 's3', name: 'HA Plumping Serum', imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=300&auto=format&fit=crop', price: 26.00, rating: 4.4, isWishlisted: false, category: 'cat_serum', concern: 'Dry & Flaky Skin'),
    ProductModel(id: 's4', name: 'Retinol Renewal Serum', imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=300&auto=format&fit=crop', price: 35.00, rating: 4.7, isWishlisted: true, category: 'cat_serum', concern: 'Anti-Aging'),
    ProductModel(id: 's5', name: 'Kojic Brightening Serum', imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=300&auto=format&fit=crop', price: 32.00, rating: 4.5, isWishlisted: false, category: 'cat_serum', concern: 'Dark Spots'),

    // Sunscreens
    ProductModel(id: 'sun1', name: 'Matte Fluid SPF 50+', imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=300&auto=format&fit=crop', price: 22.00, rating: 4.9, isWishlisted: false, category: 'cat_sunscreen', concern: 'Acne & Blemishes'),
    ProductModel(id: 'sun2', name: 'Hydrating SPF 40 Lotion', imageUrl: 'https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?q=80&w=300&auto=format&fit=crop', price: 19.00, rating: 4.5, isWishlisted: false, category: 'cat_sunscreen', concern: 'Dry & Flaky Skin'),
    ProductModel(id: 'sun3', name: 'Invisible Shield SPF 50', imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=300&auto=format&fit=crop', price: 24.00, rating: 4.7, isWishlisted: false, category: 'cat_sunscreen', concern: 'Dark Spots'),
    ProductModel(id: 'sun4', name: 'Anti-Age Sunscreen SPF 30', imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=300&auto=format&fit=crop', price: 27.00, rating: 4.6, isWishlisted: false, category: 'cat_sunscreen', concern: 'Anti-Aging'),
    ProductModel(id: 'sun5', name: 'Tinted Mineral SPF 45', imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=300&auto=format&fit=crop', price: 31.00, rating: 4.8, isWishlisted: true, category: 'cat_sunscreen', concern: 'Dark Spots'),
  ];
}
