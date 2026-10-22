import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/models/result.dart';

class HomeService {
  final ApiClient _client;

  HomeService(this._client);

  Future<Result<dynamic>> getBanners() async {
    return await _client.get(ApiEndpoints.publicSlides);
  }

  Future<Result<dynamic>> getCategories() async {
    return await _client.get(ApiEndpoints.categories);
  }

  Future<Result<dynamic>> getFeaturedProducts() async {
    return await _client.get(ApiEndpoints.featuredProducts);
  }

  Future<Result<dynamic>> getTrendingProducts() async {
    return await _client.get(ApiEndpoints.trendingProducts);
  }
  
  Future<Result<dynamic>> searchProducts(String query) async {
    return await _client.get(
      ApiEndpoints.searchProducts,
      queryParameters: {
        'q': query,
        'search': query,
      },
    );
  }
}
