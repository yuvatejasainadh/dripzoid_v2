import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/result.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/services/home_service.dart';

final homeServiceProvider = Provider<HomeService>((ref) {
  final client = ref.watch(apiClientProvider);
  return HomeService(client);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final service = ref.watch(homeServiceProvider);
  return HomeRepository(service);
});

class HomeState {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> featuredProducts;
  final List<ProductModel> trendingProducts;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const HomeState({
    this.banners = const [],
    this.categories = const [],
    this.featuredProducts = const [],
    this.trendingProducts = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastUpdated,
  });

  HomeState copyWith({
    List<BannerModel>? banners,
    List<CategoryModel>? categories,
    List<ProductModel>? featuredProducts,
    List<ProductModel>? trendingProducts,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return HomeState(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      trendingProducts: trendingProducts ?? this.trendingProducts,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    // Trigger initial load
    Future.microtask(() => loadHomeData());
    return const HomeState(isLoading: true);
  }

  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _fetchData();
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final results = await Future.wait([
      _repository.getBanners(),
      _repository.getCategories(),
      _repository.getFeaturedProducts(),
      _repository.getTrendingProducts(),
    ]);

    final bannerRes = results[0] as Result<List<BannerModel>>;
    final categoryRes = results[1] as Result<List<CategoryModel>>;
    final featuredRes = results[2] as Result<List<ProductModel>>;
    final trendingRes = results[3] as Result<List<ProductModel>>;

    String? error;
    if (bannerRes is Failure) error = (bannerRes as Failure).message;
    if (categoryRes is Failure) error ??= (categoryRes as Failure).message;
    if (featuredRes is Failure) error ??= (featuredRes as Failure).message;
    if (trendingRes is Failure) error ??= (trendingRes as Failure).message;

    state = state.copyWith(
      banners: bannerRes is Success ? (bannerRes as Success<List<BannerModel>>).data : state.banners,
      categories: categoryRes is Success ? (categoryRes as Success<List<CategoryModel>>).data : state.categories,
      featuredProducts: featuredRes is Success ? (featuredRes as Success<List<ProductModel>>).data : state.featuredProducts,
      trendingProducts: trendingRes is Success ? (trendingRes as Success<List<ProductModel>>).data : state.trendingProducts,
      isLoading: false,
      isRefreshing: false,
      errorMessage: error,
      lastUpdated: DateTime.now(),
    );
  }
}
