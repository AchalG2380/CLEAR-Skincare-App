import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkinAnalysisController extends GetxController {
  static const String _keyImage = 'last_analysis_image';
  static const String _keyConcern = 'last_analysis_concern';
  static const String _keyTime = 'last_analysis_time';
  static const String _keyScorePrefix = 'last_analysis_score_';

  final ImagePicker _picker = ImagePicker();

  var imagePath = ''.obs;
  var isScanning = false.obs;
  final scores = <String, int>{}.obs;
  var topConcern = ''.obs;
  var lastAnalysisTime = ''.obs;
  bool isTesting = false;

  @override
  void onInit() {
    super.onInit();
    loadSavedAnalysis();
  }

  Future<void> loadSavedAnalysis() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      imagePath.value = prefs.getString(_keyImage) ?? '';
      topConcern.value = prefs.getString(_keyConcern) ?? '';
      
      final savedTime = prefs.getString(_keyTime) ?? '';
      if (savedTime.isNotEmpty) {
        final parsedTime = DateTime.parse(savedTime);
        lastAnalysisTime.value = _formatTimeAgo(parsedTime);
      } else {
        lastAnalysisTime.value = '';
      }

      final concerns = ['Acne & Blemishes', 'Dry & Flaky Skin', 'Dark Spots', 'Anti-Aging'];
      final tempScores = <String, int>{};
      for (final c in concerns) {
        tempScores[c] = prefs.getInt('$_keyScorePrefix$c') ?? 0;
      }
      scores.assignAll(tempScores);
    } catch (_) {}
  }

  Future<void> pickImage(ImageSource source) async {
    if (isTesting) {
      imagePath.value = 'mock_selfie.png';
      return;
    }

    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file != null) {
        imagePath.value = file.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> analyzeImage(String path) async {
    if (path.isEmpty) return;

    isScanning.value = true;
    
    // Fixed simulation delay of 3 seconds
    await Future.delayed(Duration(seconds: isTesting ? 0 : 3));

    try {
      int seedValue = 12345;
      if (!isTesting) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // Derive a stable seed from bytes
          seedValue = bytes.length;
          for (int i = 0; i < bytes.length && i < 500; i++) {
            seedValue += bytes[i];
          }
        }
      }

      final concerns = ['Acne & Blemishes', 'Dry & Flaky Skin', 'Dark Spots', 'Anti-Aging'];
      final tempScores = <String, int>{};
      int maxScore = -1;
      String primary = concerns[0];

      for (int i = 0; i < concerns.length; i++) {
        // Stable pseudo-random score calculation between 30 and 95
        int score = 30 + ((seedValue + (i * 23)) % 66);
        tempScores[concerns[i]] = score;
        if (score > maxScore) {
          maxScore = score;
          primary = concerns[i];
        }
      }

      scores.assignAll(tempScores);
      topConcern.value = primary;
      imagePath.value = path;

      // Save to disk
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyImage, path);
      await prefs.setString(_keyConcern, primary);
      final now = DateTime.now().toIso8601String();
      await prefs.setString(_keyTime, now);
      for (final entry in tempScores.entries) {
        await prefs.setInt('$_keyScorePrefix${entry.key}', entry.value);
      }

      await loadSavedAnalysis();
      
      if (Get.context != null) {
        Get.offNamed('/skin-analysis-results');
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar('Analysis Failed', 'Could not parse image: $e', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> clearResult() async {
    try {
      imagePath.value = '';
      topConcern.value = '';
      lastAnalysisTime.value = '';
      scores.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyImage);
      await prefs.remove(_keyConcern);
      await prefs.remove(_keyTime);
      for (final c in ['Acne & Blemishes', 'Dry & Flaky Skin', 'Dark Spots', 'Anti-Aging']) {
        await prefs.remove('$_keyScorePrefix$c');
      }
    } catch (_) {}
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
