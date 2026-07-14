import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_response_model.dart';

class HomeRepository {
  final String baseUrl = 'https://your-api-base-url.com/api';

  Future<HomeResponseModel> getHomeData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HomeResponseModel.fromJson(data);
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      // Server unreachable — fall back to mock data
      return HomeResponseModel.fromJson(_getMockHomeData());
    }
  }

  Map<String, dynamic> _getMockHomeData() {
    return {
      "banners": [
        {
          "id": "b1",
          "imageUrl": "assets/images/cream.webp",
          "productActionId": "p1"
        },
        {
          "id": "b2",
          "imageUrl": "assets/images/cream.webp",
          "productActionId": "p2"
        },
        {
          "id": "b3",
          "imageUrl": "assets/images/cream2.jpg",
          "productActionId": "p3"
        }
      ],
      "categories": [
        {
          "id": "cat_cleanser",
          "name": "Cleanser",
          "imageUrl": "assets/images/moisturrizer2.webp"
        },
        {
          "id": "cat_moisturizer",
          "name": "Moisturizer",
          "imageUrl": "assets/images/moisturrizer2.webp"
        },
        {
          "id": "cat_serum",
          "name": "Serum",
          "imageUrl": "assets/images/Serum.jpg"
        },
        {
          "id": "cat_sunscreen",
          "name": "Sunscreen",
          "imageUrl": "assets/images/moisturrizer3.jpeg"
        }
      ],
      "bestSellers": [
        {
          "id": "p1",
          "name": "Vitamin C Radiance Serum",
          "imageUrl": "assets/images/Serum.jpg",
          "price": 29.99,
          "rating": 4.8,
          "isWishlisted": true
        },
        {
          "id": "p2",
          "name": "Gentle Cleansing Foam",
          "imageUrl": "assets/images/moisturrizer4.webp",
          "price": 18.50,
          "rating": 4.5,
          "isWishlisted": false
        },
        {
          "id": "p3",
          "name": "Barrier Recovery Cream",
          "imageUrl": "assets/images/cream.webp",
          "price": 24.00,
          "rating": 4.6,
          "isWishlisted": false
        }
      ],
      "newArrivals": [
        {
          "id": "p4",
          "name": "Matte Fluid SPF 50+",
          "imageUrl": "assets/images/cream2.jpg",
          "price": 22.00,
          "rating": 4.9,
          "isWishlisted": false
        },
        {
          "id": "p5",
          "name": "Night Renewal Retinol",
          "imageUrl": "assets/images/moisturrizer2.webp",
          "price": 35.00,
          "rating": 4.7,
          "isWishlisted": true
        },
        {
          "id": "p6",
          "name": "Hyaluronic Hydrating Gel",
          "imageUrl": "assets/images/moisturrizer3.jpeg",
          "price": 26.00,
          "rating": 4.4,
          "isWishlisted": false
        }
      ],
      "skinConcerns": [
        {
          "id": "con_acne",
          "name": "Acne & Blemishes",
          "imageUrl": "assets/images/moisturrizer4.webp"
        },
        {
          "id": "con_dry",
          "name": "Dry & Flaky Skin",
          "imageUrl": "assets/images/moisturrizer2.webp"
        },
        {
          "id": "con_pigment",
          "name": "Dark Spots",
          "imageUrl": "assets/images/moisturrizer3.jpeg"
        },
        {
          "id": "con_aging",
          "name": "Anti-Aging",
          "imageUrl": "assets/images/moisturrizer4.webp"
        }
      ]
    };
  }
}
