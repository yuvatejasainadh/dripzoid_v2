import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/review_eligibility_model.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_providers.dart';

class ProductDetailsState {
  final ProductModel? product;
  final List<ProductModel> relatedProducts;
  final List<ReviewModel> reviews;
  final List<QuestionModel> questions;
  final bool isLoading;
  final String? errorMessage;
  
  // Selection state
  final String selectedColor;
  final String selectedSize;
  final int quantity;
  
  // Shipping state
  final bool isCheckingShipping;
  final String? shippingMessage;
  final bool isShippingServiceable;

  // Review eligibility
  final bool canReview;
  final bool hasPurchased;
  final bool hasReviewed;
  final bool isSubmittingReview;

  // Infinite scroll pagination for related content
  final bool isLoadingMoreRelated;
  final int relatedPage;
  final bool hasReachedMaxRelated;

  const ProductDetailsState({
    this.product,
    this.relatedProducts = const [],
    this.reviews = const [],
    this.questions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedColor = '',
    this.selectedSize = '',
    this.quantity = 1,
    this.isCheckingShipping = false,
    this.shippingMessage,
    this.isShippingServiceable = false,
    this.canReview = false,
    this.hasPurchased = false,
    this.hasReviewed = false,
    this.isSubmittingReview = false,
    this.isLoadingMoreRelated = false,
    this.relatedPage = 1,
    this.hasReachedMaxRelated = false,
  });

  ProductDetailsState copyWith({
    ProductModel? product,
    List<ProductModel>? relatedProducts,
    List<ReviewModel>? reviews,
    List<QuestionModel>? questions,
    bool? isLoading,
    String? errorMessage,
    String? selectedColor,
    String? selectedSize,
    int? quantity,
    bool? isCheckingShipping,
    String? shippingMessage,
    bool? isShippingServiceable,
    bool? canReview,
    bool? hasPurchased,
    bool? hasReviewed,
    bool? isSubmittingReview,
    bool? isLoadingMoreRelated,
    int? relatedPage,
    bool? hasReachedMaxRelated,
  }) {
    return ProductDetailsState(
      product: product ?? this.product,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      reviews: reviews ?? this.reviews,
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      isCheckingShipping: isCheckingShipping ?? this.isCheckingShipping,
      shippingMessage: shippingMessage,
      isShippingServiceable: isShippingServiceable ?? this.isShippingServiceable,
      canReview: canReview ?? this.canReview,
      hasPurchased: hasPurchased ?? this.hasPurchased,
      hasReviewed: hasReviewed ?? this.hasReviewed,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      isLoadingMoreRelated: isLoadingMoreRelated ?? this.isLoadingMoreRelated,
      relatedPage: relatedPage ?? this.relatedPage,
      hasReachedMaxRelated: hasReachedMaxRelated ?? this.hasReachedMaxRelated,
    );
  }
}

final productDetailsProvider =
    StateNotifierProvider.family<ProductDetailsNotifier, ProductDetailsState, String>(
  (ref, productId) => ProductDetailsNotifier(ref, productId),
);

class ProductDetailsNotifier extends StateNotifier<ProductDetailsState> {
  final Ref _ref;
  final String _productId;

  ProductDetailsNotifier(this._ref, this._productId) : super(const ProductDetailsState()) {
    loadProductDetails();
  }

  ProductRepository get _repository => _ref.read(productRepositoryProvider);

  Future<void> loadProductDetails() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final isAuthenticated = _ref.read(authProvider).status == AuthStatus.authenticated;

    final results = await Future.wait<Result<dynamic>>([
      _repository.getProductById(_productId),
      _repository.getRelatedProducts(_productId),
      _repository.getProductReviews(_productId),
      _repository.getProductQuestions(_productId),
      if (isAuthenticated) _repository.verifyPurchase(_productId) else Future.value(Success<ReviewEligibilityModel>(ReviewEligibilityModel.empty())),
    ]);

    final Result<ProductModel> productRes = results[0] as Result<ProductModel>;
    final Result<List<ProductModel>> relatedRes = results[1] as Result<List<ProductModel>>;
    final Result<List<ReviewModel>> reviewsRes = results[2] as Result<List<ReviewModel>>;
    final Result<List<QuestionModel>> questionsRes = results[3] as Result<List<QuestionModel>>;
    final Result<ReviewEligibilityModel> eligibilityRes = results[4] as Result<ReviewEligibilityModel>;

    if (productRes is Success<ProductModel>) {
      final product = productRes.data;
      
      // Default selections
      String initialColor = '';
      if (product.colors.isNotEmpty) {
        final firstColor = product.colors.first;
        initialColor = firstColor is Map ? (firstColor['name'] ?? firstColor['label'] ?? '') : firstColor.toString();
      }

      String initialSize = '';
      final availableSizes = product.sizes.isNotEmpty
          ? product.sizes
          : (product.sizeStock?.keys.toList() ?? []);

      if (availableSizes.isNotEmpty) {
        initialSize = availableSizes.firstWhere(
          (s) => product.isSizeInStock(s),
          orElse: () => availableSizes.first,
        );
      }

      final initialStock = product.getStockForSize(initialSize.isNotEmpty ? initialSize : null);
      final initialQuantity = initialStock > 0 ? 1 : 0;

      final eligibility = eligibilityRes is Success<ReviewEligibilityModel> 
          ? eligibilityRes.data 
          : ReviewEligibilityModel.empty();

      state = state.copyWith(
        product: product,
        relatedProducts: relatedRes is Success<List<ProductModel>> ? relatedRes.data : [],
        reviews: reviewsRes is Success<List<ReviewModel>> ? reviewsRes.data : [],
        questions: questionsRes is Success<List<QuestionModel>> ? questionsRes.data : [],
        canReview: eligibility.canReview,
        hasPurchased: eligibility.hasPurchased,
        hasReviewed: eligibility.hasReviewed,
        isLoading: false,
        selectedColor: initialColor,
        selectedSize: initialSize,
        quantity: initialQuantity > 0 ? initialQuantity : 1,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (productRes as Failure).message,
      );
    }
  }

  Future<void> loadMoreRelatedProducts() async {
    if (state.isLoadingMoreRelated || state.hasReachedMaxRelated) return;

    state = state.copyWith(isLoadingMoreRelated: true);

    final nextPage = state.relatedPage + 1;
    final category = state.product?.category;

    final result = await _repository.getProducts(queryParameters: {
      'category':? category,
      'page': nextPage,
    });

    if (result is Success<List<ProductModel>>) {
      final newItems = result.data.where((p) => p.id != _productId && !state.relatedProducts.any((existing) => existing.id == p.id)).toList();
      state = state.copyWith(
        isLoadingMoreRelated: false,
        relatedProducts: [...state.relatedProducts, ...newItems],
        relatedPage: nextPage,
        hasReachedMaxRelated: newItems.isEmpty || newItems.length < 10,
      );
    } else {
      state = state.copyWith(isLoadingMoreRelated: false);
    }
  }

  Future<bool> submitReview({required int rating, String? text}) async {
    if (state.isSubmittingReview) return false;
    
    state = state.copyWith(isSubmittingReview: true);
    
    try {
      final result = await _repository.submitReview({
        'productId': _productId,
        'rating': rating,
        'text': text,
      });

      if (result is Success<Map<String, dynamic>>) {
        // Refresh reviews and eligibility
        final results = await Future.wait([
          _repository.getProductReviews(_productId),
          _repository.verifyPurchase(_productId),
        ]);

        final reviewsRes = results[0] as Result<List<ReviewModel>>;
        final eligibilityRes = results[1] as Result<ReviewEligibilityModel>;

        final eligibility = eligibilityRes is Success<ReviewEligibilityModel>
            ? eligibilityRes.data
            : ReviewEligibilityModel.empty();

        state = state.copyWith(
          isSubmittingReview: false,
          reviews: reviewsRes is Success<List<ReviewModel>> ? reviewsRes.data : state.reviews,
          canReview: eligibility.canReview,
          hasPurchased: eligibility.hasPurchased,
          hasReviewed: eligibility.hasReviewed,
        );
        return true;
      } else {
        state = state.copyWith(isSubmittingReview: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSubmittingReview: false);
      return false;
    }
  }

  void selectColor(String color) {
    state = state.copyWith(selectedColor: color);
  }

  void selectSize(String size) {
    final maxStock = _getAvailableStockForSize(size);
    final clampedQuantity = maxStock > 0 ? state.quantity.clamp(1, maxStock) : 1;
    state = state.copyWith(
      selectedSize: size,
      quantity: clampedQuantity,
    );
  }

  void updateQuantity(int quantity) {
    if (quantity < 1) return;
    
    final maxStock = _getAvailableStockForSize(state.selectedSize);
    if (maxStock > 0) {
      state = state.copyWith(quantity: quantity.clamp(1, maxStock));
    } else {
      state = state.copyWith(quantity: 1);
    }
  }

  int _getAvailableStockForSize([String? size]) {
    final product = state.product;
    if (product == null) return 0;
    final targetSize = size ?? state.selectedSize;
    return product.getStockForSize(targetSize.isNotEmpty ? targetSize : null);
  }

  Future<void> checkShipping(String pincode) async {
    if (pincode.length != 6) return;

    state = state.copyWith(isCheckingShipping: true, shippingMessage: null);

    final Result<Map<String, dynamic>> result = await _repository.checkShipping(pincode);

    state = switch (result) {
      Success(data: final data) => state.copyWith(
          isCheckingShipping: false,
          isShippingServiceable: data['serviceable'] == true,
          shippingMessage: data['success'] == true 
            ? "Expected by ${data['estimated_delivery']}" 
            : "Not serviceable to this area",
        ),
      Failure(message: final msg) => state.copyWith(
          isCheckingShipping: false,
          shippingMessage: msg,
        ),
    };
  }
}
