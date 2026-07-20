import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_theme.dart';
import '../../core/controllers/skin_analysis_controller.dart';

class SkinAnalysisScreen extends StatelessWidget {
  SkinAnalysisScreen({super.key});

  final SkinAnalysisController controller = Get.find<SkinAnalysisController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Skin Analysis',
          style: TextStyle(color: AppTheme.primaryText, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final path = controller.imagePath.value;
          final isScanning = controller.isScanning.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Instructions & Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      isScanning ? 'Analyzing Skin Details...' : 'Scan Your Face',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For best results: Good lighting, no makeup, face the camera directly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Image Frame / Face outline guide
              Expanded(
                child: Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isScanning ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.3),
                        width: 4,
                      ),
                      boxShadow: [
                        if (isScanning)
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Placeholder outline or Image view
                          if (path.isEmpty)
                            Container(
                              color: AppTheme.cardBackground,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.face_retouching_natural,
                                    size: 80,
                                    color: AppTheme.primary.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No Photo Selected',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          else if (path == 'mock_selfie.png')
                            Container(
                              color: AppTheme.cardBackground,
                              child: Center(
                                child: Icon(
                                  Icons.account_circle,
                                  size: 160,
                                  color: AppTheme.primary,
                                ),
                              ),
                            )
                          else
                            Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              width: 280,
                              height: 280,
                            ),

                          // Scanning Animation Sweep Line
                          if (isScanning)
                            const ScanningAnimationOverlay(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Buttons Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: isScanning
                    ? Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: AppTheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              'Running simulated bio-scan...',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (path.isNotEmpty) ...[
                            ElevatedButton.icon(
                              onPressed: () => controller.analyzeImage(path),
                              icon: const Icon(Icons.psychology_outlined),
                              label: const Text('Start AI Analysis'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.buttonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => controller.pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text('Take Photo'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primary,
                                    side: BorderSide(color: AppTheme.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => controller.pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_outlined),
                                  label: const Text('From Gallery'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primary,
                                    side: BorderSide(color: AppTheme.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (path.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => controller.clearResult(),
                              child: Text(
                                'Clear Photo',
                                style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }
}

class ScanningAnimationOverlay extends StatefulWidget {
  const ScanningAnimationOverlay({super.key});

  @override
  State<ScanningAnimationOverlay> createState() => _ScanningAnimationOverlayState();
}

class _ScanningAnimationOverlayState extends State<ScanningAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, -1.0 + (_controller.value * 2.0)),
          child: Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
