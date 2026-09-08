import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../checkout/presentation/providers/checkout_notifier.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderHistoryState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? errorMessage;
  final String selectedFilter;

  const OrderHistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedFilter = 'All',
  });

  OrderHistoryState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? errorMessage,
    String? selectedFilter,
  }) {
    return OrderHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<OrderModel> get filteredOrders {
    if (selectedFilter == 'All') return orders;
    
    return orders.where((order) {
      final status = order.status.toLowerCase();
      
      if (selectedFilter == 'Active') {
        return status != 'cancelled' && status != 'delivered' && status != 'returned';
      }
      if (selectedFilter == 'Delivered') {
        return status == 'delivered';
      }
      if (selectedFilter == 'Cancelled') {
        return status == 'cancelled';
      }
      return true;
    }).toList();
  }

  int get totalCount => orders.length;
  int get activeCount => orders.where((o) => 
    o.status.toLowerCase() != 'cancelled' && 
    o.status.toLowerCase() != 'delivered' && 
    o.status.toLowerCase() != 'returned').length;
  int get cancelledCount => orders.where((o) => o.status.toLowerCase() == 'cancelled').length;
}

final orderHistoryProvider = NotifierProvider<OrderHistoryNotifier, OrderHistoryState>(() {
  return OrderHistoryNotifier();
});

class OrderHistoryNotifier extends Notifier<OrderHistoryState> {
  @override
  OrderHistoryState build() {
    return const OrderHistoryState();
  }

  OrderRepository get _repository => ref.read(orderRepositoryProvider);

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.getUserOrders();

      state = switch (result) {
        Success(data: final List<OrderModel> orders) => state.copyWith(orders: orders, isLoading: false),
        Failure(message: final String msg) => state.copyWith(errorMessage: msg, isLoading: false),
      };
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}
