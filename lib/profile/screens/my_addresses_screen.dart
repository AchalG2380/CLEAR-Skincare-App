import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/app_widgets.dart';
import '../../checkout/controllers/checkout_controller.dart';
import '../../checkout/data/models/address_model.dart';

class MyAddressesScreen extends StatelessWidget {
  MyAddressesScreen({super.key});

  // Reuse an already-active CheckoutController (e.g. if the user is mid-checkout)
  // instead of overwriting it — Get.put() would otherwise silently wipe any
  // in-progress selected address / payment method / cart summary.
  final CheckoutController controller = Get.isRegistered<CheckoutController>()
      ? Get.find<CheckoutController>()
      : Get.put(CheckoutController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Refresh addresses list on screen entry
    controller.fetchAddresses();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          AppStrings.savedAddressesTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAddresses.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColor.primary),
                );
              }

              if (controller.addresses.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final address = controller.addresses[index];
                  return _buildAddressCard(context, address);
                },
              );
            }),
          ),

          // Add address button at bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showAddressFormSheet(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  AppStrings.addAddress,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Individual Address Management Card ────────────────────────────────────
  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColor.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.labelPhone}: ${address.phone}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions Column
          Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () =>
                    _showAddressFormSheet(context, address: address),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColor.error,
                  size: 20,
                ),
                onPressed: () => _showDeleteConfirmation(context, address.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Bottom Sheet Input Form for Add/Edit ──────────────────────────────────
  void _showAddressFormSheet(BuildContext context, {AddressModel? address}) {
    final isEdit = address != null;

    final nameController = TextEditingController(text: address?.name ?? '');
    final phoneController = TextEditingController(text: address?.phone ?? '');
    final streetController = TextEditingController(text: address?.street ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final stateController = TextEditingController(text: address?.state ?? '');
    final pincodeController = TextEditingController(
      text: address?.pincode ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? AppStrings.editAddress : AppStrings.addAddress,
                        style: const TextStyle(
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

                  _buildFormTextField(
                    controller: nameController,
                    label: AppStrings.labelFullName,
                    hint: AppStrings.hintFullName,
                    validator: (val) =>
                        val == null || val.isEmpty ? AppStrings.valFieldRequired : null,
                  ),
                  _buildFormTextField(
                    controller: phoneController,
                    label: AppStrings.labelPhone,
                    hint: AppStrings.hintPhone,
                    keyboardType: TextInputType.phone,
                    validator: (val) =>
                        val == null || val.isEmpty ? AppStrings.valFieldRequired : null,
                  ),
                  _buildFormTextField(
                    controller: streetController,
                    label: AppStrings.labelStreetAddress,
                    hint: AppStrings.hintStreet,
                    validator: (val) =>
                        val == null || val.isEmpty ? AppStrings.valFieldRequired : null,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildFormTextField(
                          controller: cityController,
                          label: AppStrings.labelCity,
                          hint: AppStrings.hintCity,
                          validator: (val) =>
                              val == null || val.isEmpty ? AppStrings.valFieldRequired : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormTextField(
                          controller: stateController,
                          label: AppStrings.labelState,
                          hint: AppStrings.hintState,
                          validator: (val) =>
                              val == null || val.isEmpty ? AppStrings.valFieldRequired : null,
                        ),
                      ),
                    ],
                  ),

                  _buildFormTextField(
                    controller: pincodeController,
                    label: AppStrings.labelPincode,
                    hint: AppStrings.hintPincode,
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? AppStrings.valFieldRequired : null,
                  ),

                  const SizedBox(height: 24),

                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: controller.isSavingAddress.value
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close bottom sheet immediately
                                  if (isEdit) {
                                    final newAddress = AddressModel(
                                      id: address.id,
                                      name: nameController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      street: streetController.text.trim(),
                                      city: cityController.text.trim(),
                                      state: stateController.text.trim(),
                                      pincode: pincodeController.text.trim(),
                                    );
                                    await controller.updateAddress(newAddress);
                                  } else {
                                    await controller.addAddress(
                                      name: nameController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      street: streetController.text.trim(),
                                      city: cityController.text.trim(),
                                      state: stateController.text.trim(),
                                      pincode: pincodeController.text.trim(),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: controller.isSavingAddress.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isEdit ? AppStrings.saveChanges : AppStrings.addAddress,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              filled: true,
              fillColor: AppColor.inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.primary.withValues(alpha: 0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.error,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Delete Confirmation Dialog ────────────────────────────────────────────
  void _showDeleteConfirmation(BuildContext context, String addressId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            AppStrings.deleteAddressTitle,
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            AppStrings.deleteAddressConfirm,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(color: Colors.white30),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog immediately
                await controller.deleteAddress(addressId);
              },
              child: const Text(
                AppStrings.delete,
                style: TextStyle(color: AppColor.error),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Empty state for addresses management ──────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return const SkincareEmptyState(
      icon: Icons.location_off_outlined,
      title: AppStrings.emptyAddressesTitle,
      description: AppStrings.emptyAddressesDesc,
    );
  }
}
