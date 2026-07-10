import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/checkout_controller.dart';
import '../data/models/address_model.dart';

class CheckoutAddressScreen extends StatelessWidget {
  CheckoutAddressScreen({super.key});

  // Inject CheckoutController (screen-scoped, initialized here)
  final CheckoutController controller = Get.put(CheckoutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF130538),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Checkout',
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
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF8C6EFF)),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Select Shipping Address',
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
                    ...controller.addresses.map((addr) => _buildAddressCard(addr)),

                  const SizedBox(height: 16),

                  // Add New Address Button
                  GestureDetector(
                    onTap: () => _showAddAddressSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(15, 255, 255, 255),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromARGB(60, 140, 110, 255),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Color(0xFF8C6EFF), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add New Address',
                            style: TextStyle(
                              color: Color(0xFF8C6EFF),
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
                ? const Color.fromARGB(35, 140, 110, 255)
                : const Color.fromARGB(15, 255, 255, 255),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8C6EFF)
                  : const Color.fromARGB(30, 140, 110, 255),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio Icon selector
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? const Color(0xFF8C6EFF) : Colors.white54,
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
                      'Phone: ${address.phone}',
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
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_outlined, color: Colors.white30, size: 48),
          SizedBox(height: 12),
          Text(
            'No saved addresses found.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─── Bottom continue bar ────────────────────────────────────────────────────
  Widget _buildBottomActionPanel() {
    return Container(
      color: const Color(0xFF130538),
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
                backgroundColor: const Color(0xFF8C6EFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF8C6EFF).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Continue to Payment',
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
        decoration: const BoxDecoration(
          color: Color(0xFF130538),
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
                      'Add New Address',
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
                  label: 'Full Name',
                  hint: 'Enter receiver name',
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // Phone
                _buildFormTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: 'Enter mobile number',
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // Street Address
                _buildFormTextField(
                  controller: streetController,
                  label: 'Street Address',
                  hint: 'House/Flat No, Building, Street Name',
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // City & State Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFormTextField(
                        controller: cityController,
                        label: 'City',
                        hint: 'Enter City',
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormTextField(
                        controller: stateController,
                        label: 'State',
                        hint: 'Enter State',
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                // Pincode
                _buildFormTextField(
                  controller: pincodeController,
                  label: 'Pincode',
                  hint: 'Enter 6-digit Pincode',
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 24),

                // Submit Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isSavingAddress.value
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              Navigator.of(context).pop(); // Close bottom sheet immediately
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
                      backgroundColor: const Color(0xFF8C6EFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSavingAddress.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save & Select Address',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                )),
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
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: const Color(0xFF8C6EFF),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
          filled: true,
          fillColor: const Color.fromARGB(15, 255, 255, 255),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromARGB(30, 140, 110, 255)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8C6EFF)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
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
      color: const Color(0xFF130538),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _buildStep(0, 'Address'),
          _buildLine(0),
          _buildStep(1, 'Payment'),
          _buildLine(1),
          _buildStep(2, 'Review'),
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
                ? const Color(0xFF8C6EFF)
                : const Color.fromARGB(40, 255, 255, 255),
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
                    color: isCompleted || isActive ? Colors.white : Colors.white54,
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
                : (isCompleted ? const Color(0xFFC7B6FF) : Colors.white38),
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
            ? const Color(0xFF8C6EFF)
            : const Color.fromARGB(40, 255, 255, 255),
      ),
    );
  }
}
