import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../checkout/presentation/providers/checkout_notifier.dart';
import '../../data/models/order_model.dart';
import '../../data/models/shipment_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderDetailsState {
  final OrderModel? order;
  final ShipmentModel? shipment;
  final bool isLoading;
  final bool isTracking;
  final bool isCancelling;
  final String? errorMessage;

  const OrderDetailsState({
    this.order,
    this.shipment,
    this.isLoading = false,
    this.isTracking = false,
    this.isCancelling = false,
    this.errorMessage,
  });

  OrderDetailsState copyWith({
    OrderModel? order,
    ShipmentModel? shipment,
    bool? isLoading,
    bool? isTracking,
    bool? isCancelling,
    String? errorMessage,
  }) {
    return OrderDetailsState(
      order: order ?? this.order,
      shipment: shipment ?? this.shipment,
      isLoading: isLoading ?? this.isLoading,
      isTracking: isTracking ?? this.isTracking,
      isCancelling: isCancelling ?? this.isCancelling,
      errorMessage: errorMessage,
    );
  }
}

final orderDetailsProvider =
    StateNotifierProvider.family<OrderDetailsNotifier, OrderDetailsState, String>(
  (ref, orderId) => OrderDetailsNotifier(ref, orderId),
);

class OrderDetailsNotifier extends StateNotifier<OrderDetailsState> {
  final Ref _ref;
  final String _orderId;

  OrderDetailsNotifier(this._ref, this._orderId) : super(const OrderDetailsState()) {
    loadOrderDetails();
  }

  OrderRepository get _repository => _ref.read(orderRepositoryProvider);

  Future<void> loadOrderDetails() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getOrderDetails(_orderId);

    if (result is Success<OrderModel>) {
      state = state.copyWith(order: result.data, isLoading: false);
      trackOrder(); // Auto-track on load
    } else {
      state = state.copyWith(isLoading: false, errorMessage: (result as Failure).message);
    }
  }

  Future<void> trackOrder() async {
    state = state.copyWith(isTracking: true);
    final result = await _repository.trackOrder(_orderId);

    if (result is Success<ShipmentModel>) {
      state = state.copyWith(shipment: result.data, isTracking: false);
    } else {
      state = state.copyWith(isTracking: false);
    }
  }

  Future<bool> cancelOrder() async {
    state = state.copyWith(isCancelling: true, errorMessage: null);
    final result = await _repository.cancelOrder(_orderId);

    if (result is Success) {
      await loadOrderDetails();
      state = state.copyWith(isCancelling: false);
      return true;
    } else {
      state = state.copyWith(isCancelling: false, errorMessage: (result as Failure).message);
      return false;
    }
  }

  Future<String?> getInvoiceUrl() async {
    final result = await _repository.getInvoiceUrl(_orderId);
    return result is Success<String> ? result.data : null;
  }
}
