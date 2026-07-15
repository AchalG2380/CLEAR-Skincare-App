import '../../../cart/data/models/cart_item_model.dart';
import '../../../checkout/data/models/address_model.dart';

class TrackingStageModel {
  final String title;
  final String? timestamp;
  final bool isCompleted;

  TrackingStageModel({
    required this.title,
    this.timestamp,
    required this.isCompleted,
  });

  factory TrackingStageModel.fromJson(Map<String, dynamic> json) {
    return TrackingStageModel(
      title: json['title'] as String? ?? '',
      timestamp: json['timestamp'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'timestamp': timestamp, 'isCompleted': isCompleted};
  }
}

class OrderModel {
  final String id;
  final String date;
  final double total;
  final String status; // 'Processing', 'Shipped', 'Delivered', 'Cancelled'
  final List<CartItemModel> items;
  final AddressModel address;
  final String paymentMethod;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final List<TrackingStageModel> trackingStages;

  OrderModel({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.trackingStages,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Processing',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      address: AddressModel.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
      paymentMethod: json['paymentMethod'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      trackingStages:
          (json['trackingStages'] as List<dynamic>?)
              ?.map(
                (e) => TrackingStageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'total': total,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'address': address.toJson(),
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'trackingStages': trackingStages.map((e) => e.toJson()).toList(),
    };
  }
}
