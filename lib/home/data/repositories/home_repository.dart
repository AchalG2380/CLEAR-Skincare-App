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
          "imageUrl": "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=600&auto=format&fit=crop",
          "productActionId": "p1"
        },
        {
          "id": "b2",
          "imageUrl": "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=600&auto=format&fit=crop",
          "productActionId": "p2"
        },
        {
          "id": "b3",
          "imageUrl": "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=600&auto=format&fit=crop",
          "productActionId": "p3"
        }
      ],
      "categories": [
        {
          "id": "cat_cleanser",
          "name": "Cleanser",
          "imageUrl": "https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?q=80&w=200&auto=format&fit=crop"
        },
        {
          "id": "cat_moisturizer",
          "name": "Moisturizer",
          "imageUrl": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=200&auto=format&fit=crop"
        },
        {
          "id": "cat_serum",
          "name": "Serum",
          "imageUrl": "https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=200&auto=format&fit=crop"
        },
        {
          "id": "cat_sunscreen",
          "name": "Sunscreen",
          "imageUrl": "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=200&auto=format&fit=crop"
        }
      ],
      "bestSellers": [
        {
          "id": "p1",
          "name": "Vitamin C Radiance Serum",
          "imageUrl": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=200&auto=format&fit=crop",
          "price": 29.99,
          "rating": 4.8,
          "isWishlisted": true
        },
        {
          "id": "p2",
          "name": "Gentle Cleansing Foam",
          "imageUrl": "https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?q=80&w=200&auto=format&fit=crop",
          "price": 18.50,
          "rating": 4.5,
          "isWishlisted": false
        },
        {
          "id": "p3",
          "name": "Barrier Recovery Cream",
          "imageUrl": "https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=200&auto=format&fit=crop",
          "price": 24.00,
          "rating": 4.6,
          "isWishlisted": false
        }
      ],
      "newArrivals": [
        {
          "id": "p4",
          "name": "Matte Fluid SPF 50+",
          "imageUrl": "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=200&auto=format&fit=crop",
          "price": 22.00,
          "rating": 4.9,
          "isWishlisted": false
        },
        {
          "id": "p5",
          "name": "Night Renewal Retinol",
          "imageUrl": "https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=200&auto=format&fit=crop",
          "price": 35.00,
          "rating": 4.7,
          "isWishlisted": true
        },
        {
          "id": "p6",
          "name": "Hyaluronic Hydrating Gel",
          "imageUrl": "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=200&auto=format&fit=crop",
          "price": 26.00,
          "rating": 4.4,
          "isWishlisted": false
        }
      ],
      "skinConcerns": [
        {
          "id": "con_acne",
          "name": "Acne & Blemishes",
          "imageUrl": "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=200&auto=format&fit=crop"
        },
        {
          "id": "con_dry",
          "name": "Dry & Flaky Skin",
          "imageUrl": "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=200&auto=format&fit=crop"
        },
        {
          "id": "con_pigment",
          "name": "Dark Spots",
          "imageUrl": "https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=200&auto=format&fit=crop"
        },
        {
          "id": "con_aging",
          "name": "Anti-Aging",
          "imageUrl": "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=200&auto=format&fit=crop"
        }
      ]
    };
  }
}
