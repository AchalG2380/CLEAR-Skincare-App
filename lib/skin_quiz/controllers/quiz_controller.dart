import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/quiz_question_model.dart';

class QuizController extends GetxController {
  final PageController pageController = PageController();

  var currentIndex = 0.obs;
  final int totalQuestions = QuizData.questions.length;

  // Tracks which option index the user picked for each question, so the
  // "Back" button can restore their previous answer instead of resetting it.
  final selectedOptionIndex = <int, int>{}.obs;

  var resultSkinType = Rxn<SkinType>();

  QuizQuestion get currentQuestion => QuizData.questions[currentIndex.value];

  double get progress => (currentIndex.value + 1) / totalQuestions;

  void selectAnswer(int optionIndex) {
    selectedOptionIndex[currentIndex.value] = optionIndex;

    // Small delay so the user sees their selection highlight before advancing
    Future.delayed(const Duration(milliseconds: 250), () {
      if (currentIndex.value < totalQuestions - 1) {
        goToNext();
      } else {
        _computeResult();
      }
    });
  }

  void goToNext() {
    currentIndex.value++;
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void goToPrevious() {
    if (currentIndex.value == 0) return;
    currentIndex.value--;
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _computeResult() {
    final scores = <SkinType, int>{for (final type in SkinType.values) type: 0};

    selectedOptionIndex.forEach((questionIndex, optionIndex) {
      final skinType =
          QuizData.questions[questionIndex].options[optionIndex].skinType;
      scores[skinType] = (scores[skinType] ?? 0) + 1;
    });

    // Pick the highest-scoring skin type; ties resolve to whichever
    // was reached first in SkinType.values order (a reasonable, stable default).
    SkinType winner = SkinType.oily;
    int highestScore = -1;
    scores.forEach((type, score) {
      if (score > highestScore) {
        highestScore = score;
        winner = type;
      }
    });

    resultSkinType.value = winner;
    _saveResult(winner);
  }

  Future<void> _saveResult(SkinType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('skinType', type.name);
  }

  /// Lets other parts of the app (e.g. a future "Recommended for you"
  /// section on Home) read the last quiz result without retaking it.
  static Future<SkinType?> getSavedResult() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('skinType');
    if (saved == null) return null;
    try {
      return SkinType.values.byName(saved);
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
