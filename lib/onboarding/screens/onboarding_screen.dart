import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/app_widgets.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingController controller = Get.put(OnboardingController());
  final PageController _pageController = PageController();

  final List<Map<String, String>> _slides = [
    {
      "title": AppStrings.onboardingSlide1Title,
      "subtitle": AppStrings.onboardingSlide1Subtitle,
      "imageUrl": "assets/images/moisturrizer2.webp",
    },
    {
      "title": AppStrings.onboardingSlide2Title,
      "subtitle": AppStrings.onboardingSlide2Subtitle,
      "imageUrl": "assets/images/cream.webp",
    },
    {
      "title": AppStrings.onboardingSlide3Title,
      "subtitle": AppStrings.onboardingSlide3Subtitle,
      "imageUrl": "assets/images/Serum.jpg",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Logo & Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Obx(
                    () =>
                        controller.currentPage.value < controller.totalPages - 1
                        ? TextButton(
                            onPressed: controller.completeOnboarding,
                            child: Text(
                              AppStrings.skip,
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(width: 40),
                  ),
                ],
              ),
            ),

            // PageView Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  controller.updatePage(index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Responsive Illustration image
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: getSkincareImageProvider(
                                slide["imageUrl"]!,
                              ),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Slide Title
                        Text(
                          slide["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Slide Subtitle
                        Text(
                          slide["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator Dots & Next / Get Started Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators Row
                  Obx(
                    () => Row(
                      children: List.generate(_slides.length, (index) {
                        final isSelected =
                            controller.currentPage.value == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isSelected ? 24 : 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.dividerColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Next / Complete Button
                  Obx(() {
                    final isLastPage =
                        controller.currentPage.value ==
                        controller.totalPages - 1;
                    return ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          controller.completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isLastPage ? AppStrings.getStarted : AppStrings.next,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
