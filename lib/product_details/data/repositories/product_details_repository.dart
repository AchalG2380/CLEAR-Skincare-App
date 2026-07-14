import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_details_model.dart';

class ProductDetailsRepository {
  final String baseUrl = 'https://your-api-base-url.com/api';

  Future<ProductDetailsModel> getProductDetails(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$productId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ProductDetailsModel.fromJson(data);
      }
      throw Exception('Server returned status ${response.statusCode}');
    } catch (_) {
      return _getMockDetails(productId);
    }
  }

  ProductDetailsModel _getMockDetails(String id) {
    // Generate detailed mocks based on product type
    if (id == 's1') {
      return ProductDetailsModel(
        id: 's1',
        name: 'Vitamin C Radiance Serum',
        description: 'Brighten, hydrate, and shield your skin with this high-potency Vitamin C serum. Specially formulated with 10% L-Ascorbic Acid, Hyaluronic Acid, and Vitamin E to diminish dark spots, refine skin texture, and restore a youthful, radiant complexion.',
        price: 29.99,
        rating: 4.8,
        imageUrls: [
          'assets/images/Serum.jpg',
          'assets/images/moisturrizer4.webp',
          'assets/images/moisturrizer2.webp',
        ],
        ingredients: 'Aqua (Water), L-Ascorbic Acid (Vitamin C) 10%, Propylene Glycol, Glycerin, Sodium Hyaluronate (Hyaluronic Acid), Tocopherol (Vitamin E), Phenoxyethanol, Ethylhexylglycerin.',
        benefits: [
          'Brightens dark spots and hyperpigmentation',
          'Promotes collagen synthesis to reduce fine lines',
          'Provides daily antioxidant protection against pollutants',
          'Replenishes moisture barriers instantly',
        ],
        usage: 'Apply 3-5 drops onto clean, dry face and neck in the morning. Gently pat until fully absorbed. Follow with moisturizer and SPF. Avoid direct contact with eyes.',
        reviews: [
          ReviewModel(reviewerName: 'Sophia Carter', rating: 5.0, date: '2 days ago', comment: 'Absolutely love this serum! My skin has a noticeable glow and my acne scars have faded in just two weeks!'),
          ReviewModel(reviewerName: 'James Miller', rating: 4.0, date: '1 week ago', comment: 'Very hydrating formula. Feels lightweight and non-sticky. Docking one star because it took a few days to get used to the scent.'),
          ReviewModel(reviewerName: 'Emily Davis', rating: 5.0, date: '3 weeks ago', comment: 'My dermatologist recommended this and it did not disappoint. Perfect for morning skin routine.'),
        ],
      );
    } else if (id == 'sun1') {
      return ProductDetailsModel(
        id: 'sun1',
        name: 'Matte Fluid SPF 50+',
        description: 'Advanced fluid sunscreen with SPF 50+ protection against UVA and UVB rays. Delivers a zero-shine matte finish, making it perfect for oily or combination skin. Lightweight, fast-absorbing, and completely white-cast free.',
        price: 22.00,
        rating: 4.9,
        imageUrls: [
          'assets/images/moisturrizer2.webp',
          'assets/images/moisturrizer3.jpeg',
        ],
        ingredients: 'Zinc Oxide, Titanium Dioxide, Purified Water, Silica, Dimethicone, Camellia Sinensis (Green Tea) Leaf Extract, Xanthan Gum, Potassium Sorbate.',
        benefits: [
          'Broad-spectrum SPF 50+ UVA/UVB protection',
          'Ultra-matte finish with oil control controls sebum all day',
          'Lightweight fluid texture, zero white cast',
          'Non-comedogenic (won\'t clog pores)',
        ],
        usage: 'Shake well before use. Apply generously to face and neck 15 minutes before sun exposure. Reapply every 2 hours or after sweating/swimming.',
        reviews: [
          ReviewModel(reviewerName: 'David K.', rating: 5.0, date: 'Yesterday', comment: 'Finally a sunscreen that doesn\'t make me look greasy! Love the dry-touch feel.'),
          ReviewModel(reviewerName: 'Sarah L.', rating: 5.0, date: '3 days ago', comment: 'Perfect under makeup. No rolling, no white cast, and great sun protection.'),
        ],
      );
    } else if (id == 'm1') {
      return ProductDetailsModel(
        id: 'm1',
        name: 'Barrier Recovery Cream',
        description: 'A deeply nourishing, rich moisturizing cream designed to repair and reinforce compromised skin barriers. Infused with three essential ceramides, fatty acids, and phytosphingosine to seal in hydration and protect against irritation.',
        price: 24.00,
        rating: 4.6,
        imageUrls: [
          'assets/images/cream.webp',
          'assets/images/cream2.jpg',
        ],
        ingredients: 'Ceramide NP, Ceramide AP, Ceramide EOP, Phytosphingosine, Cholesterol, Hyaluronic Acid, Glycerin, Purified Water.',
        benefits: [
          'Repairs and restores dry or damaged skin barriers',
          'Prevents transepidermal water loss (TEWL)',
          'Calms redness, itching, and flakiness',
          'Hypoallergenic, fragrance-free formula',
        ],
        usage: 'Apply liberally to face, neck, and dry areas as often as needed, or as directed by a dermatologist. Massage gently until absorbed.',
        reviews: [
          ReviewModel(reviewerName: 'Jessica T.', rating: 5.0, date: '4 days ago', comment: 'This saved my skin after a harsh chemical peel. Very rich but doesn\'t feel heavy.'),
          ReviewModel(reviewerName: 'Michael P.', rating: 4.0, date: '1 week ago', comment: 'Great moisturizer. Very good for winter flakiness. Might be too heavy for summer oily skin.'),
        ],
      );
    } else {
      // Default fallback details for other items
      return ProductDetailsModel(
        id: id,
        name: 'Gentle Foaming Cleanser',
        description: 'A soft, hydrating daily cleanser that melts away makeup, sebum, and environmental impurities while keeping the skin barrier fully hydrated. Formulated with green tea extract and amino acids.',
        price: 18.50,
        rating: 4.5,
        imageUrls: [
          'assets/images/moisturrizer2.webp',
          'assets/images/moisturrizer3.jpeg',
        ],
        ingredients: 'Green Tea Extract, Glycerin, Water, Sodium Cocoyl Isethionate, Citric Acid, Glyceryl Stearate.',
        benefits: [
          'Thoroughly cleanses without stripping moisture',
          'Rich, creamy foaming lather leaves skin refreshed',
          'Balances pH levels of the skin',
        ],
        usage: 'Dispense a small amount onto wet hands, lather well, and gently massage onto face in circular motions. Rinse thoroughly with lukewarm water.',
        reviews: [
          ReviewModel(reviewerName: 'Grace A.', rating: 4.5, date: '3 days ago', comment: 'Very mild and gentle. Clean feeling without the dryness!'),
        ],
      );
    }
  }
}
