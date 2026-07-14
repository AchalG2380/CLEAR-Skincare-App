import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/quiz_controller.dart';
import 'skin_quiz_screen.dart';
import '../data/models/quiz_question_model.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();
    final skinType = controller.resultSkinType.value;

    // Defensive fallback — shouldn't happen since this screen is only
    // reached after _computeResult() sets a value, but avoids a crash
    // if the controller was somehow disposed/reset in between.
    if (skinType == null) {
      return const Scaffold(
        backgroundColor: AppColor.backgroundColor,
        body: Center(
          child: Text(
            'Something went wrong. Please retake the quiz.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primary.withValues(alpha: 0.15),
                          border: Border.all(color: AppColor.primary, width: 2),
                        ),
                        child: const Icon(
                          Icons.spa_outlined,
                          color: AppColor.primary,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your Skin Type Is',
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        skinType.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        skinType.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.secondaryText,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColor.dividerColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: AppColor.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                skinType.routineTip,
                                style: const TextStyle(
                                  color: AppColor.secondaryText,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Reuses the exact same filter mechanism Home's skin-concern
                    // grid already uses — no new listing logic needed.
                    Get.offNamed(
                      '/product-listing',
                      arguments: {'concern': skinType.matchingConcern},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Shop Recommended Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.off(() => SkinQuizScreen()),
                child: const Text(
                  'Retake Quiz',
                  style: TextStyle(color: AppColor.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
