import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clear/core/controllers/skin_analysis_controller.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  test('SkinAnalysisController runs stable scanning logic and formats top concern', () async {
    final controller = Get.put(SkinAnalysisController()..isTesting = true);

    // Wait for onInit async tasks to complete
    await Future.delayed(const Duration(milliseconds: 100));

    // Load initial empty states
    await controller.loadSavedAnalysis();
    expect(controller.imagePath.value, '');
    expect(controller.topConcern.value, '');
    expect(controller.scores.values.every((v) => v == 0), true);

    // Pick a photo in testing mode
    await controller.pickImage(ImageSource.camera); // Passes mock source argument
    expect(controller.imagePath.value, 'mock_selfie.png');

    // Run analysis
    await controller.analyzeImage('mock_selfie.png');

    // Verify stable scores were generated (seed value is 12345)
    // Acne: 30 + (12345 % 66) = 30 + 3 = 33
    // Dry: 30 + ((12345 + 23) % 66) = 30 + 26 = 56
    // Spots: 30 + ((12345 + 46) % 66) = 30 + 49 = 79
    // Aging: 30 + ((12345 + 69) % 66) = 30 + 6 = 36
    // Highest score is 'Dark Spots' with 79 points
    expect(controller.scores['Dark Spots'], 79);
    expect(controller.topConcern.value, 'Dark Spots');

    // Wipe results
    await controller.clearResult();
    expect(controller.imagePath.value, '');
    expect(controller.topConcern.value, '');
    expect(controller.scores.isEmpty, true);
  });
}
