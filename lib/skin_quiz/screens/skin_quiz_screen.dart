import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/quiz_controller.dart';
import '../data/models/quiz_question_model.dart';
import 'quiz_result_screen.dart';

class SkinQuizScreen extends StatelessWidget {
  SkinQuizScreen({super.key});

  final QuizController controller = Get.put(QuizController());

  @override
  Widget build(BuildContext context) {
    // Navigate to the result screen once scoring completes
    ever(controller.resultSkinType, (SkinType? type) {
      if (type != null) {
        Get.off(() => const QuizResultScreen());
      }
    });

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.totalQuestions,
                itemBuilder: (context, index) {
                  final question = QuizData.questions[index];
                  return _QuestionPage(
                    question: question,
                    questionIndex: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Obx(
            () => IconButton(
              onPressed: controller.currentIndex.value == 0
                  ? () => Get.back()
                  : controller.goToPrevious,
              icon: Icon(
                controller.currentIndex.value == 0
                    ? Icons.close
                    : Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Skin Type Quiz',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48), // balances the leading IconButton
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              'Question ${controller.currentIndex.value + 1} of ${controller.totalQuestions}',
              style: const TextStyle(color: AppColor.textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: controller.progress,
                minHeight: 6,
                backgroundColor: AppColor.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColor.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final QuizQuestion question;
  final int questionIndex;

  const _QuestionPage({required this.question, required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(question.options.length, (i) {
            return Obx(() {
              final isSelected =
                  controller.selectedOptionIndex[questionIndex] == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionTile(
                  text: question.options[i].text,
                  isSelected: isSelected,
                  onTap: () => controller.selectAnswer(i),
                ),
              );
            });
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withValues(alpha: 0.15)
              : AppColor.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColor.primary : AppColor.textDim,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColor.secondaryText,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
