import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/controllers/skin_analysis_controller.dart';

class SkinAnalysisResultsScreen extends StatelessWidget {
  SkinAnalysisResultsScreen({super.key});

  final SkinAnalysisController controller = Get.find<SkinAnalysisController>();

  final Map<String, String> _concernDescriptions = {
    'Acne & Blemishes': 'Clogged pores, excess sebum, and breakouts benefit from clarifying ingredients like Salicylic Acid, Niacinamide, and Zinc to purify and calm skin.',
    'Dry & Flaky Skin': 'Dryness and flaking indicate a compromised moisture barrier. Hyaluronic Acid, Ceramides, and rich emollients help lock in deep hydration.',
    'Dark Spots': 'Hyperpigmentation, sun spots, and uneven tone respond well to brightening agents such as Vitamin C, Retinol, and Alpha Arbutin.',
    'Anti-Aging': 'Fine lines, wrinkles, and loss of firmness are targeted by collagen-boosting Peptides, Antioxidants, and daily broad-spectrum SPF protection.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Analysis Results',
          style: TextStyle(color: AppTheme.primaryText, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.primaryText),
          onPressed: () {
            // Clear and go back to home
            controller.clearResult();
            Get.offAllNamed('/home');
          },
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final topConcernStr = controller.topConcern.value;
          final scoresMap = controller.scores;

          if (topConcernStr.isEmpty || scoresMap.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text(
                    'No active analysis data.',
                    style: TextStyle(color: AppTheme.primaryText, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.offNamed('/skin-analysis'),
                    child: const Text('Go to Analysis'),
                  ),
                ],
              ),
            );
          }

          final description = _concernDescriptions[topConcernStr] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Primary Concern Callout Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.spa_outlined, color: AppTheme.primary, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'PRIMARY SKIN CONCERN',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        topConcernStr,
                        style: TextStyle(
                          color: AppTheme.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Concern Scoreboard Section
                Text(
                  'Analysis Scoreboard',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: scoresMap.entries.map((entry) {
                      final concernName = entry.key;
                      final scoreVal = entry.value;
                      final isPrimary = concernName == topConcernStr;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  concernName,
                                  style: TextStyle(
                                    color: isPrimary ? AppTheme.primary : AppTheme.primaryText,
                                    fontSize: 13.5,
                                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  '$scoreVal/100',
                                  style: TextStyle(
                                    color: isPrimary ? AppTheme.primary : AppTheme.secondaryText,
                                    fontSize: 13.5,
                                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: scoreVal / 100,
                                minHeight: 8,
                                color: isPrimary ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.4),
                                backgroundColor: AppTheme.inputFill,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 28),

                // Visible Ethical Disclaimer Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorBg.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.errorBg.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Disclaimer: This skin scan is simulated for demonstration and portfolio representation only. It does not replace professional medical diagnosis, advice, or dermatological treatment.',
                          style: TextStyle(
                            color: AppTheme.textDim,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // CTA action buttons
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(
                      '/product-listing',
                      arguments: {'concern': topConcernStr},
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text('Shop Products for $topConcernStr'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () {
                    controller.clearResult();
                    Get.offNamed('/skin-analysis');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retake / Try Different Photo'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }
}
