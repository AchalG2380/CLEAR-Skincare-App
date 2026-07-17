import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/data/models/product_model.dart';
import '../data/models/routine_model.dart';

class RoutinePlannerController extends GetxController {
  final routines = <RoutineModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRoutines();
  }

  Future<void> loadRoutines() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('skincare_routines');

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        routines.assignAll(
          list.map((e) => RoutineModel.fromJson(e as Map<String, dynamic>)).toList(),
        );
      } else {
        // Load default empty routines
        _loadDefaultRoutines();
      }
    } catch (_) {
      _loadDefaultRoutines();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDefaultRoutines() {
    routines.assignAll([
      RoutineModel(
        title: 'Morning Routine',
        steps: [
          RoutineStepModel(stepName: 'Cleanser'),
          RoutineStepModel(stepName: 'Toner'),
          RoutineStepModel(stepName: 'Serum'),
          RoutineStepModel(stepName: 'Moisturizer'),
          RoutineStepModel(stepName: 'Sunscreen'),
        ],
      ),
      RoutineModel(
        title: 'Evening Routine',
        steps: [
          RoutineStepModel(stepName: 'Cleanser'),
          RoutineStepModel(stepName: 'Toner'),
          RoutineStepModel(stepName: 'Treatment'),
          RoutineStepModel(stepName: 'Night Cream'),
        ],
      ),
    ]);
  }

  Future<void> saveRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(routines.map((e) => e.toJson()).toList());
      await prefs.setString('skincare_routines', jsonStr);
    } catch (_) {}
  }

  void assignProduct(String routineTitle, String stepName, ProductModel product) {
    final rIndex = routines.indexWhere((r) => r.title == routineTitle);
    if (rIndex == -1) return;

    final routine = routines[rIndex];
    final sIndex = routine.steps.indexWhere((s) => s.stepName == stepName);
    if (sIndex == -1) return;

    final updatedSteps = List<RoutineStepModel>.from(routine.steps);
    updatedSteps[sIndex] = RoutineStepModel(stepName: stepName, product: product);

    routines[rIndex] = RoutineModel(title: routineTitle, steps: updatedSteps);
    saveRoutines();
  }

  void clearProduct(String routineTitle, String stepName) {
    final rIndex = routines.indexWhere((r) => r.title == routineTitle);
    if (rIndex == -1) return;

    final routine = routines[rIndex];
    final sIndex = routine.steps.indexWhere((s) => s.stepName == stepName);
    if (sIndex == -1) return;

    final updatedSteps = List<RoutineStepModel>.from(routine.steps);
    updatedSteps[sIndex] = RoutineStepModel(stepName: stepName, product: null);

    routines[rIndex] = RoutineModel(title: routineTitle, steps: updatedSteps);
    saveRoutines();
  }
}
