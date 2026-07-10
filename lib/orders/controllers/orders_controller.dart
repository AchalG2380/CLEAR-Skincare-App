import 'package:get/get.dart';
import '../../core/controllers/base_controller.dart';
import '../data/models/order_model.dart';
import '../data/repositories/orders_repository.dart';

class OrdersController extends BaseSkincareController {
  final OrdersRepository _repo = OrdersRepository();

  // Observable states
  final orders = <OrderModel>[].obs;
  
  final orderDetails = Rxn<OrderModel>();
  var isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final result = await runSafeApiCall(() async {
      // Artificial short delay to show the skeleton shimmer loader
      await Future.delayed(const Duration(milliseconds: 1000));
      return _repo.getOrders();
    });

    if (result != null) {
      orders.assignAll(result);
    }
  }

  Future<void> fetchOrderDetails(String id) async {
    try {
      isDetailLoading.value = true;
      errorMessage.value = '';
      orderDetails.value = null;

      final details = await runSafeApiCall(() async {
        // Artificial short delay to show skeleton shimmer details loader
        await Future.delayed(const Duration(milliseconds: 800));
        return _repo.getOrderDetails(id);
      }, showLoading: false);

      if (details != null) {
        orderDetails.value = details;
      }
    } finally {
      isDetailLoading.value = false;
    }
  }
}
