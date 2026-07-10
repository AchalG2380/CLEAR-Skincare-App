import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/product_widgets.dart';
import '../controllers/orders_controller.dart';
import '../data/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  OrderDetailsScreen({super.key});

  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    // Read the orderId passed as argument
    final String? orderId = Get.arguments as String?;

    if (orderId != null && orderId.isNotEmpty) {
      // Trigger details fetch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchOrderDetails(orderId);
      });
    }

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: const SkincareAppBar(title: 'Order Details'),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8C6EFF)),
          );
        }

        final order = controller.orderDetails.value;
        if (order == null) {
          return _buildErrorState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchOrderDetails(order.id),
          color: const Color(0xFF8C6EFF),
          backgroundColor: const Color(0xFF130538),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order metadata title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ordered on ${order.date}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusLabel(order.status),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Delivery Tracking Timeline Section
                const Text(
                  'Delivery Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTrackingTimeline(order.trackingStages),

                const Divider(color: Colors.white10, height: 36),

                // 2. Shipping Address Section
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildAddressCard(order.address),

                const SizedBox(height: 20),

                // 3. Payment Method Section
                const Text(
                  'Payment Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildPaymentCard(order.paymentMethod),

                const SizedBox(height: 20),

                // 4. Ordered Items list
                const Text(
                  'Items Ordered',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildItemsList(order.items),

                const SizedBox(height: 20),

                // 5. Total cost break up
                const Text(
                  'Cost Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildPriceSummary(order),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Visual Timeline Construction ──────────────────────────────────────────
  Widget _buildTrackingTimeline(List<TrackingStageModel> stages) {
    // Find the highest completed index to identify the pulsing "active" dot
    int activeIndex = -1;
    for (int i = 0; i < stages.length; i++) {
      if (stages[i].isCompleted) {
        activeIndex = i;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 255, 255, 255),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color.fromARGB(30, 140, 110, 255),
          width: 1,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stages.length,
        itemBuilder: (context, idx) {
          final stage = stages[idx];
          final isFirst = idx == 0;
          final isLast = idx == stages.length - 1;
          final isPulsing =
              idx == activeIndex && activeIndex != stages.length - 1;

          // Connective line is colored if the NEXT stage is done
          final isLineColored =
              idx < stages.length - 1 && stages[idx + 1].isCompleted;

          return IntrinsicHeight(
            child: Row(
              children: [
                // Left Column: Dot & Connective pipe line
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      // Connection line going UP
                      if (!isFirst)
                        Container(
                          width: 2,
                          height: 10,
                          color: stage.isCompleted
                              ? const Color(0xFF8C6EFF)
                              : const Color.fromARGB(40, 255, 255, 255),
                        )
                      else
                        const SizedBox(height: 10),

                      // Circle dot
                      if (isPulsing)
                        const _PulsingTimelineDot()
                      else
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stage.isCompleted
                                ? const Color(0xFF8C6EFF)
                                : Colors.transparent,
                            border: Border.all(
                              color: stage.isCompleted
                                  ? const Color(0xFF8C6EFF)
                                  : const Color.fromARGB(70, 255, 255, 255),
                              width: 2,
                            ),
                          ),
                        ),

                      // Connection line going DOWN
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: isLineColored
                                ? const Color(0xFF8C6EFF)
                                : const Color.fromARGB(40, 255, 255, 255),
                          ),
                        )
                      else
                        const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right Column: Details text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.title,
                          style: TextStyle(
                            color: stage.isCompleted
                                ? Colors.white
                                : Colors.white30,
                            fontSize: 14,
                            fontWeight: stage.isCompleted
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage.timestamp ?? 'Pending',
                          style: TextStyle(
                            color: stage.isCompleted
                                ? Colors.white54
                                : Colors.white24,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Reusable Address Card ──────────────────────────────────────────────────
  Widget _buildAddressCard(dynamic address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(30, 140, 110, 255),
          width: 1,
        ),
      ),
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
            'Phone: ${address.phone}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Payment Details Card ───────────────────────────────────────────────────
  Widget _buildPaymentCard(String method) {
    String name = 'Cash on Delivery';
    IconData icon = Icons.payments_outlined;

    if (method == 'Card') {
      name = 'Credit / Debit Card';
      icon = Icons.credit_card_outlined;
    } else if (method == 'UPI') {
      name = 'UPI Wallet';
      icon = Icons.account_balance_wallet_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(30, 140, 110, 255),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Items List ─────────────────────────────────────────────────────────────
  Widget _buildItemsList(List items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(30, 140, 110, 255),
          width: 1,
        ),
      ),
      child: Column(
        children: items.map<Widget>((item) {
          final p = item.product;
          return SkincareCartItemRow(
            name: p.name,
            imageUrl: p.imageUrl,
            price: p.price,
            quantity: item.quantity,
            isEditable: false,
          );
        }).toList(),
      ),
    );
  }

  // ─── Price Break Up summary ─────────────────────────────────────────────────
  Widget _buildPriceSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(30, 140, 110, 255),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Discount',
              '-\$${order.discount.toStringAsFixed(2)}',
              valueColor: Colors.redAccent,
            ),
          ],
          const SizedBox(height: 8),
          _buildPriceRow(
            'Delivery Fee',
            order.deliveryFee == 0.0
                ? 'FREE'
                : '\$${order.deliveryFee.toStringAsFixed(2)}',
            valueColor: order.deliveryFee == 0.0 ? Colors.green : Colors.white,
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildPriceRow(
            'Total Amount',
            '\$${order.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white60,
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFFC7B6FF) : valueColor,
            fontSize: isTotal ? 16 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─── Status Text Style Color badge ───
  Widget _buildStatusLabel(String status) {
    Color textColor = Colors.white;
    switch (status.toLowerCase()) {
      case 'delivered':
        textColor = const Color(0xFF81C784);
        break;
      case 'shipped':
        textColor = const Color(0xFFFFB74D);
        break;
      case 'processing':
        textColor = const Color(0xFFE0E0E0);
        break;
      case 'cancelled':
        textColor = const Color(0xFFE57373);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Failed to load order details.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Pulsing Timeline Dot ─────────────────────────────────────────────
class _PulsingTimelineDot extends StatefulWidget {
  const _PulsingTimelineDot();

  @override
  State<_PulsingTimelineDot> createState() => _PulsingTimelineDotState();
}

class _PulsingTimelineDotState extends State<_PulsingTimelineDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 8.0,
      end: 18.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glowing outer pulse
              Container(
                width: _pulse.value,
                height: _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8C6EFF).withValues(alpha: 0.3),
                ),
              ),
              // Inner solid dot
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8C6EFF),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF8C6EFF), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
