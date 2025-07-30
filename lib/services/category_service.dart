// lib/services/category_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/api_response.dart';
import '../models/pagination_meta.dart';
import 'dio_client.dart';

final categoryServiceProvider = Provider((ref) => CategoryService());

class CategoryService {
  final DioClient _dioClient;

  CategoryService() : _dioClient = DioClient();

  // ========== GET CATEGORIES ==========

  /// Get all categories
  Future<ApiResponse<List<CategoryModel>>> getAllCategories({
    bool? isActive,
    String? search,
    String sortBy = 'name', // 'name', 'createdAt', 'updatedAt'
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
        'sortBy': sortBy,
      };

      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dioClient.dio.get(
        '/categories',
        queryParameters: queryParams,
      );

      final categories = (response.data['categories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      final pagination = response.data['pagination'] != null
          ? PaginationMeta.fromJson(response.data['pagination'])
          : null;

      return ApiResponse.success(categories, pagination: pagination);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get category by ID
  Future<ApiResponse<CategoryModel>> getCategoryDetail(
      String categoryId) async {
    try {
      final response = await _dioClient.dio.get('/categories/$categoryId');
      final category = CategoryModel.fromJson(response.data);
      return ApiResponse.success(category);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get featured categories
  Future<ApiResponse<List<CategoryModel>>> getFeaturedCategories({
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/categories/featured',
        queryParameters: {'limit': limit},
      );

      final categories = (response.data['categories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get categories by store
  Future<ApiResponse<List<CategoryModel>>> getCategoriesByStore(
    String storeId, {
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/stores/$storeId/categories',
        queryParameters: {'limit': limit},
      );

      final categories = (response.data['categories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get popular categories (most used)
  Future<ApiResponse<List<CategoryModel>>> getPopularCategories({
    int limit = 10,
    String timeframe = 'month', // 'week', 'month', 'year'
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/categories/popular',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );

      final categories = (response.data['categories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH CATEGORIES ==========

  /// Search categories by name or description
  Future<ApiResponse<List<CategoryModel>>> searchCategories(
    String query, {
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/categories/search',
        queryParameters: {
          'q': query,
          'limit': limit,
          'page': page,
        },
      );

      final categories = (response.data['categories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== CATEGORY STATISTICS ==========

  /// Get category statistics (number of stores, deals, etc.)
  Future<ApiResponse<Map<String, dynamic>>> getCategoryStats(
    String categoryId,
  ) async {
    try {
      final response =
          await _dioClient.dio.get('/categories/$categoryId/stats');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get all categories with their deal counts
  Future<ApiResponse<List<Map<String, dynamic>>>>
      getCategoriesWithCounts() async {
    try {
      final response = await _dioClient.dio.get('/categories/with-counts');
      final categoriesWithCounts = List<Map<String, dynamic>>.from(
        response.data['categories'] ?? [],
      );
      return ApiResponse.success(categoriesWithCounts);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== USER PREFERENCES ==========

  /// Get user's preferred categories
  Future<ApiResponse<List<CategoryModel>>> getUserPreferredCategories() async {
    try {
      final response = await _dioClient.dio.get('/user/preferred-categories');
      final categories = (response.data['preferredCategories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();
      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Add category to user preferences
  Future<ApiResponse<bool>> addToPreferences(String categoryId) async {
    try {
      await _dioClient.dio.post(
        '/user/preferred-categories/add',
        data: {'categoryId': categoryId},
      );
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Remove category from user preferences
  Future<ApiResponse<bool>> removeFromPreferences(String categoryId) async {
    try {
      await _dioClient.dio.post(
        '/user/preferred-categories/remove',
        data: {'categoryId': categoryId},
      );
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== CATEGORY MANAGEMENT (ADMIN) ==========

  /// Create new category (Admin only)
  Future<ApiResponse<CategoryModel>> createCategory({
    required String name,
    String? description,
    String? iconUrl,
    String? parentCategoryId,
    bool isActive = true,
  }) async {
    try {
      final response = await _dioClient.dio.post('/categories', data: {
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'parentCategoryId': parentCategoryId,
        'isActive': isActive,
      });

      final category = CategoryModel.fromJson(response.data);
      return ApiResponse.success(category);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Update category (Admin only)
  Future<ApiResponse<CategoryModel>> updateCategory({
    required String categoryId,
    String? name,
    String? description,
    String? iconUrl,
    String? parentCategoryId,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (iconUrl != null) data['iconUrl'] = iconUrl;
      if (parentCategoryId != null) data['parentCategoryId'] = parentCategoryId;
      if (isActive != null) data['isActive'] = isActive;

      final response =
          await _dioClient.dio.put('/categories/$categoryId', data: data);
      final category = CategoryModel.fromJson(response.data);
      return ApiResponse.success(category);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete category (Admin only)
  Future<ApiResponse<bool>> deleteCategory(String categoryId) async {
    try {
      await _dioClient.dio.delete('/categories/$categoryId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SUBCATEGORIES ==========

  /// Get subcategories of a parent category
  Future<ApiResponse<List<CategoryModel>>> getSubcategories(
    String parentCategoryId, {
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/categories/$parentCategoryId/subcategories',
        queryParameters: {'limit': limit},
      );

      final subcategories = (response.data['subcategories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      return ApiResponse.success(subcategories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get category hierarchy (parent with all children)
  Future<ApiResponse<Map<String, dynamic>>> getCategoryHierarchy(
    String categoryId,
  ) async {
    try {
      final response =
          await _dioClient.dio.get('/categories/$categoryId/hierarchy');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== CATEGORY DEALS ==========

  /// Get active deals for a category
  Future<ApiResponse<Map<String, dynamic>>> getCategoryDeals(
    String categoryId, {
    String? dealType, // 'flyer', 'coupon', 'both'
    bool activeOnly = true,
    String sortBy = 'createdAt',
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
      };

      if (dealType != null) queryParams['dealType'] = dealType;
      if (activeOnly) queryParams['activeOnly'] = activeOnly;

      final response = await _dioClient.dio.get(
        '/categories/$categoryId/deals',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get stores in a category
  Future<ApiResponse<List<dynamic>>> getCategoryStores(
    String categoryId, {
    double? latitude,
    double? longitude,
    double? radius,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };

      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;

      final response = await _dioClient.dio.get(
        '/categories/$categoryId/stores',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data['stores'] ?? []);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== CATEGORY ANALYTICS ==========

  /// Track category interaction
  Future<ApiResponse<bool>> trackCategoryInteraction({
    required String categoryId,
    required String action, // 'view', 'search', 'select', 'prefer'
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dioClient.dio.post('/analytics/category-interaction', data: {
        'categoryId': categoryId,
        'action': action,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return ApiResponse.success(true);
    } catch (e) {
      // Don't fail on analytics errors
      return ApiResponse.success(true);
    }
  }

  /// Get category trends
  Future<ApiResponse<Map<String, dynamic>>> getCategoryTrends({
    String timeframe = 'month',
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/analytics/category-trends',
        queryParameters: {
          'timeframe': timeframe,
          'limit': limit,
        },
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== ERROR HANDLING ==========

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          switch (statusCode) {
            case 400:
              return data?['message'] ?? 'Invalid category request.';
            case 401:
              return 'Authentication failed. Please login again.';
            case 403:
              return 'Access denied. You don\'t have permission to access categories.';
            case 404:
              return data?['message'] ?? 'Category not found.';
            case 409:
              return data?['message'] ?? 'Category already exists.';
            case 422:
              return data?['message'] ?? 'Invalid category data.';
            case 429:
              return 'Too many requests. Please try again later.';
            case 500:
              return 'Category service error. Please try again later.';
            default:
              return data?['message'] ?? 'Failed to process category request.';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'Network error. Please check your internet connection.';
          }
          return 'Network error. Please check your connection.';
        default:
          return 'Something went wrong with category service.';
      }
    }
    return 'Category service error: ${error.toString()}';
  }
}
