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
    final statusVal = json['status'] as String? ?? json['orderStatus'] as String? ?? 'Processing';
    final rawDate = json['date'] as String? ?? json['createdAt'] as String? ?? '';
    final formattedDate = _formatDate(rawDate);

    return OrderModel(
      id: (json['_id'] ?? json['id']) as String? ?? '',
      date: formattedDate.isNotEmpty ? formattedDate : rawDate,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: statusVal,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      address: json['address'] is Map
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : AddressModel(
              id: json['address'] as String? ?? '',
              name: '',
              phone: '',
              street: '',
              city: '',
              pincode: '',
              state: '',
            ),
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['shipping'] as num?)?.toDouble() ?? (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      trackingStages:
          (json['trackingStages'] as List<dynamic>?)
              ?.map(
                (e) => TrackingStageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          _generateTrackingStages(statusVal, formattedDate.isNotEmpty ? formattedDate : rawDate),
    );
  }

  static String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final parsed = DateTime.parse(isoString);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[parsed.month - 1];
      final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
      final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$month ${parsed.day}, ${parsed.year}, $hour:$minute $ampm';
    } catch (_) {
      return '';
    }
  }

  static List<TrackingStageModel> _generateTrackingStages(String status, String dateStr) {
    final stages = <String>['Order Placed', 'Order Confirmed', 'Shipped', 'Out for Delivery', 'Delivered'];
    if (status == 'Cancelled') {
      return [
        TrackingStageModel(title: 'Order Placed', timestamp: dateStr, isCompleted: true),
        TrackingStageModel(title: 'Cancelled', timestamp: dateStr, isCompleted: true),
      ];
    }
    
    int completedUpTo = 0;
    if (status == 'Placed') completedUpTo = 0;
    else if (status == 'Processing') completedUpTo = 1;
    else if (status == 'Shipped') completedUpTo = 2;
    else if (status == 'Delivered') completedUpTo = 4;
    
    return List.generate(stages.length, (index) {
      final isCompleted = index <= completedUpTo;
      return TrackingStageModel(
        title: stages[index],
        timestamp: isCompleted ? (index == 0 ? dateStr : '') : null,
        isCompleted: isCompleted,
      );
    });
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
