import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_theme.dart';
import '../controllers/routine_planner_controller.dart';
import '../data/models/routine_model.dart';
import 'widgets/product_picker_sheet.dart';
import '../../../home/data/models/product_model.dart';
import '../../../core/widgets/app_widgets.dart';

class RoutinePlannerScreen extends StatelessWidget {
  RoutinePlannerScreen({super.key});

  final RoutinePlannerController controller = Get.put(RoutinePlannerController());

  Future<void> _openProductPicker(
    BuildContext context,
    String routineTitle,
    String stepName,
  ) async {
    final ProductModel? selected = await showModalBottomSheet<ProductModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductPickerSheet(stepName: stepName),
    );

    if (selected != null) {
      controller.assignProduct(routineTitle, stepName, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Obx(() => Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppTheme.backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Skincare Routine Planner',
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textMuted,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.wb_sunny_outlined),
                    text: 'Morning Routine',
                  ),
                  Tab(
                    icon: Icon(Icons.nightlight_round_outlined),
                    text: 'Evening Routine',
                  ),
                ],
              ),
            ),
            body: controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : TabBarView(
                    children: [
                      _buildRoutineList(context, 'Morning Routine', const Color(0xFFFFB300)),
                      _buildRoutineList(context, 'Evening Routine', const Color(0xFF5E35B1)),
                    ],
                  ),
          )),
    );
  }

  Widget _buildRoutineList(BuildContext context, String routineTitle, Color accentColor) {
    final routineIndex = controller.routines.indexWhere((r) => r.title == routineTitle);
    if (routineIndex == -1) return const SizedBox.shrink();

    final routine = controller.routines[routineIndex];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: routine.steps.length,
      itemBuilder: (ctx, index) {
        final step = routine.steps[index];
        final isLast = index == routine.steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline graphics (Number node & vertical line)
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 110, // approximate connector height
                    color: AppTheme.dividerColor,
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Step Content Box
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.stepName,
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  step.product != null
                      ? _buildAssignedProductCard(context, routineTitle, step)
                      : _buildUnassignedPlaceholder(context, routineTitle, step, accentColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignedProductCard(
    BuildContext context,
    String routineTitle,
    RoutineStepModel step,
  ) {
    final product = step.product!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.white, // blend white product images
              child: getSkincareImage(
                product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 20),
            onPressed: () => _openProductPicker(context, routineTitle, step.stepName),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
            onPressed: () => controller.clearProduct(routineTitle, step.stepName),
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedPlaceholder(
    BuildContext context,
    String routineTitle,
    RoutineStepModel step,
    Color accentColor,
  ) {
    return InkWell(
      onTap: () => _openProductPicker(context, routineTitle, step.stepName),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.dividerColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_outlined,
              color: accentColor.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add ${step.stepName}',
              style: TextStyle(
                color: AppTheme.textDim,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
