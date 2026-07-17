import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../controllers/checkout_controller.dart';
import '../data/models/address_model.dart';

class CheckoutAddressScreen extends StatelessWidget {
  CheckoutAddressScreen({super.key});

  // Inject CheckoutController (screen-scoped, initialized here)
  final CheckoutController controller = Get.put(CheckoutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          AppStrings.checkoutTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Multi-step indicator
          const CheckoutStepIndicator(currentStep: 0),

          // Scrollable Addresses list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAddresses.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    AppStrings.selectShippingAddress,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Saved Addresses
                  if (controller.addresses.isEmpty)
                    _buildEmptyAddresses()
                  else
                    ...controller.addresses.map(
                      (addr) => _buildAddressCard(addr),
                    ),

                  const SizedBox(height: 16),

                  // Add New Address Button
                  GestureDetector(
                    onTap: () => _showAddAddressSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.23),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppTheme.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            AppStrings.addAddress,
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          // Bottom Action Button
          _buildBottomActionPanel(),
        ],
      ),
    );
  }

  // ─── Individual Address Card ────────────────────────────────────────────────
  Widget _buildAddressCard(AddressModel address) {
    return Obx(() {
      final isSelected = controller.selectedAddress.value?.id == address.id;
      return GestureDetector(
        onTap: () {
          controller.selectedAddress.value = address;
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.15)
                : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.primary.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio Icon selector
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppTheme.primary : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 12),

              // Address description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.street,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      '${address.city}, ${address.state} - ${address.pincode}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppStrings.labelPhone}: ${address.phone}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Empty state when no addresses exist ────────────────────────────────────
  Widget _buildEmptyAddresses() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_outlined, color: AppTheme.textHint, size: 48),
          const SizedBox(height: 12),
          Text(
            AppStrings.noSavedAddressesFound,
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─── Bottom continue bar ────────────────────────────────────────────────────
  Widget _buildBottomActionPanel() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isEnabled = controller.selectedAddress.value != null;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isEnabled
                  ? () => Get.toNamed('/checkout-payment')
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.buttonColor.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                AppStrings.continueToPayment,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Bottom Sheet Address Form ──────────────────────────────────────────────
  void _showAddAddressSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final pincodeController = TextEditingController();
    final stateController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.addAddress,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Name
                _buildFormTextField(
                  controller: nameController,
                  label: AppStrings.labelFullName,
                  hint: AppStrings.hintFullName,
                  validator: (val) => val == null || val.isEmpty
                      ? AppStrings.valFieldRequired
                      : null,
                ),

                // Phone
                _buildFormTextField(
                  controller: phoneController,
                  label: AppStrings.labelPhone,
                  hint: AppStrings.hintPhone,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.isEmpty
                      ? AppStrings.valFieldRequired
                      : null,
                ),

                // Street Address
                _buildFormTextField(
                  controller: streetController,
                  label: AppStrings.labelStreetAddress,
                  hint: AppStrings.hintStreet,
                  validator: (val) => val == null || val.isEmpty
                      ? AppStrings.valFieldRequired
                      : null,
                ),

                // City & State Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFormTextField(
                        controller: cityController,
                        label: AppStrings.labelCity,
                        hint: AppStrings.hintCity,
                        validator: (val) => val == null || val.isEmpty
                            ? AppStrings.valFieldRequired
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormTextField(
                        controller: stateController,
                        label: AppStrings.labelState,
                        hint: AppStrings.hintState,
                        validator: (val) => val == null || val.isEmpty
                            ? AppStrings.valFieldRequired
                            : null,
                      ),
                    ),
                  ],
                ),

                // Pincode
                _buildFormTextField(
                  controller: pincodeController,
                  label: AppStrings.labelPincode,
                  hint: AppStrings.hintPincode,
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty
                      ? AppStrings.valFieldRequired
                      : null,
                ),

                const SizedBox(height: 24),

                // Submit Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSavingAddress.value
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(
                                  context,
                                ).pop(); // Close bottom sheet immediately
                                await controller.addAddress(
                                  name: nameController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  street: streetController.text.trim(),
                                  city: cityController.text.trim(),
                                  pincode: pincodeController.text.trim(),
                                  state: stateController.text.trim(),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSavingAddress.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              AppStrings.saveSelectAddress,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: AppTheme.primaryText, fontSize: 14),
        cursorColor: AppTheme.primary,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 12),
          filled: true,
          fillColor: AppTheme.inputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppTheme.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppTheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppTheme.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── Step Indicator Custom Widget ───────────────────────────────────────────
class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;

  const CheckoutStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _buildStep(0, AppStrings.stepAddress),
          _buildLine(0),
          _buildStep(1, AppStrings.stepPayment),
          _buildLine(1),
          _buildStep(2, AppStrings.stepReview),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title) {
    final isCompleted = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? AppTheme.primary
                : AppTheme.dividerColor.withValues(alpha: 0.15),
            border: Border.all(
              color: isActive ? Colors.white : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    color: isCompleted || isActive
                        ? Colors.white
                        : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (isCompleted ? AppTheme.primary : Colors.white38),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int index) {
    final isCompleted = currentStep > index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 1.5,
        color: isCompleted
            ? AppTheme.primary
            : AppTheme.dividerColor.withValues(alpha: 0.15),
      ),
    );
  }
}
