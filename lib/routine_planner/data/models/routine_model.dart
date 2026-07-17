import '../../../home/data/models/product_model.dart';

class RoutineStepModel {
  final String stepName; // Cleanser, Toner, Serum, Moisturizer, Sunscreen, Treatment, Night Cream
  final ProductModel? product;

  RoutineStepModel({required this.stepName, this.product});

  factory RoutineStepModel.fromJson(Map<String, dynamic> json) {
    return RoutineStepModel(
      stepName: json['stepName'] ?? '',
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepName': stepName,
        'product': product?.toJson(),
      };
}

class RoutineModel {
  final String title; // "Morning Routine" or "Evening Routine"
  final List<RoutineStepModel> steps;

  RoutineModel({required this.title, required this.steps});

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    final stepsList = (json['steps'] as List<dynamic>?) ?? [];
    return RoutineModel(
      title: json['title'] ?? '',
      steps: stepsList
          .map((e) => RoutineStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'steps': steps.map((e) => e.toJson()).toList(),
      };
}
