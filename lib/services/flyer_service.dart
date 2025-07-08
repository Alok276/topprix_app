// lib/services/flyer_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flyer_model.dart';
import '../models/flyer_item_model.dart';
import '../models/api_response.dart';
import '../models/pagination_meta.dart';
import 'dio_client.dart';

final flyerServiceProvider = Provider((ref) => FlyerService());

class FlyerService {
  final DioClient _dioClient;
  FlyerService() : _dioClient = DioClient();

  // ========== GET FLYERS ==========

  /// Get all flyers with optional filters
  Future<ApiResponse<List<FlyerModel>>> getFlyers({
    String? storeId,
    String? categoryId,
    bool? isActive,
    bool? isSponsored,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (storeId != null) queryParams['storeId'] = storeId;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (isSponsored != null)
        queryParams['isSponsored'] = isSponsored.toString();

      final response = await _dioClient.dio.get(
        '/flyers',
        queryParameters: queryParams,
      );

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      final pagination = response.data['pagination'] != null
          ? PaginationMeta.fromJson(response.data['pagination'])
          : null;

      return ApiResponse.success(flyers, pagination: pagination);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get featured/sponsored flyers for home page
  Future<ApiResponse<List<FlyerModel>>> getFeaturedFlyers({
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get('/flyers', queryParameters: {
        'isSponsored': 'true',
        'isActive': 'true',
        'limit': limit,
        'offset': 0,
      });

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get trending flyers (active and recent)
  Future<ApiResponse<List<FlyerModel>>> getTrendingFlyers({
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get('/flyers', queryParameters: {
        'isActive': 'true',
        'limit': limit,
        'offset': 0,
      });

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get flyers by specific store
  Future<ApiResponse<List<FlyerModel>>> getFlyersByStore(
    String storeId, {
    bool activeOnly = true,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'storeId': storeId,
        'limit': limit,
        'offset': offset,
      };

      if (activeOnly) queryParams['isActive'] = 'true';

      final response = await _dioClient.dio.get(
        '/flyers',
        queryParameters: queryParams,
      );

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get flyers by category
  Future<ApiResponse<List<FlyerModel>>> getFlyersByCategory(
    String categoryId, {
    bool activeOnly = true,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'categoryId': categoryId,
        'limit': limit,
        'offset': offset,
      };

      if (activeOnly) queryParams['isActive'] = 'true';

      final response = await _dioClient.dio.get(
        '/flyers',
        queryParameters: queryParams,
      );

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get expiring flyers (ending soon)
  Future<ApiResponse<List<FlyerModel>>> getExpiringFlyers({
    int hoursRemaining = 24,
    int limit = 20,
  }) async {
    try {
      final response = await getFlyers(
        isActive: true,
        limit: limit,
      );

      if (response.success && response.data != null) {
        final expiringFlyers = response.data!.where((flyer) {
          final timeRemaining = flyer.endDate.difference(DateTime.now());
          return timeRemaining.inHours <= hoursRemaining &&
              timeRemaining.inHours > 0;
        }).toList();

        // Sort by expiration time (soonest first)
        expiringFlyers.sort((a, b) => a.endDate.compareTo(b.endDate));

        return ApiResponse.success(expiringFlyers);
      }

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== GET SINGLE FLYER ==========

  /// Get flyer by ID with full details
  Future<ApiResponse<FlyerModel>> getFlyerById(String flyerId) async {
    try {
      final response = await _dioClient.dio.get('/flyers/$flyerId');
      final flyer = FlyerModel.fromJson(response.data);
      return ApiResponse.success(flyer);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get flyer details with analytics tracking
  Future<ApiResponse<FlyerModel>> getFlyerDetail(
    String flyerId, {
    String? userId,
  }) async {
    try {
      final response = await _dioClient.dio.get('/flyers/$flyerId');
      final flyer = FlyerModel.fromJson(response.data);

      // Track view analytics if userId provided
      if (userId != null) {
        _trackFlyerView(flyerId, userId);
      }

      return ApiResponse.success(flyer);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SAVE/UNSAVE FLYERS ==========

  /// Save/bookmark a flyer for the user
  Future<ApiResponse<bool>> saveFlyer(String flyerId) async {
    try {
      await _dioClient.dio.post('/flyers/save', data: {
        'flyerId': flyerId,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Remove saved flyer
  Future<ApiResponse<bool>> unsaveFlyer(String flyerId) async {
    try {
      await _dioClient.dio.post('/flyers/unsave', data: {
        'flyerId': flyerId,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get user's saved flyers
  Future<ApiResponse<List<FlyerModel>>> getUserSavedFlyers(
      String userId) async {
    try {
      final response = await _dioClient.dio.get('/users/$userId/flyers');
      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();
      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Check if flyer is saved by user
  Future<ApiResponse<bool>> isFlyerSaved(String flyerId, String userId) async {
    try {
      final response = await _dioClient.dio
          .get('/flyers/$flyerId/saved', queryParameters: {'userId': userId});
      final isSaved = response.data['isSaved'] as bool;
      return ApiResponse.success(isSaved);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== CREATE FLYERS (Admin/Retailer) ==========

  /// Create a new flyer
  Future<ApiResponse<FlyerModel>> createFlyer({
    required String title,
    required String storeId,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    bool isSponsored = false,
    List<String>? categoryIds,
  }) async {
    try {
      final response = await _dioClient.dio.post('/flyers', data: {
        'title': title,
        'storeId': storeId,
        'description': description,
        'imageUrl': imageUrl,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isSponsored': isSponsored,
        'categoryIds': categoryIds,
      });

      final flyer = FlyerModel.fromJson(response.data);
      return ApiResponse.success(flyer);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Update existing flyer
  Future<ApiResponse<FlyerModel>> updateFlyer({
    required String flyerId,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    bool? isSponsored,
    List<String>? categoryIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      if (startDate != null) data['startDate'] = startDate.toIso8601String();
      if (endDate != null) data['endDate'] = endDate.toIso8601String();
      if (isSponsored != null) data['isSponsored'] = isSponsored;
      if (categoryIds != null) data['categoryIds'] = categoryIds;

      final response = await _dioClient.dio.put('/flyers/$flyerId', data: data);
      final flyer = FlyerModel.fromJson(response.data);
      return ApiResponse.success(flyer);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete a flyer
  Future<ApiResponse<bool>> deleteFlyer(String flyerId) async {
    try {
      await _dioClient.dio.delete('/flyers/$flyerId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== FLYER ITEMS MANAGEMENT ==========

  /// Add item to flyer
  Future<ApiResponse<FlyerItemModel>> addFlyerItem({
    required String flyerId,
    required String name,
    String? description,
    double? originalPrice,
    double? salePrice,
    String? imageUrl,
  }) async {
    try {
      final response = await _dioClient.dio.post('/flyers/items', data: {
        'flyerId': flyerId,
        'name': name,
        'description': description,
        'originalPrice': originalPrice,
        'salePrice': salePrice,
        'imageUrl': imageUrl,
      });

      final item = FlyerItemModel.fromJson(response.data);
      return ApiResponse.success(item);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Update flyer item
  Future<ApiResponse<FlyerItemModel>> updateFlyerItem({
    required String itemId,
    String? name,
    String? description,
    double? originalPrice,
    double? salePrice,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (originalPrice != null) data['originalPrice'] = originalPrice;
      if (salePrice != null) data['salePrice'] = salePrice;
      if (imageUrl != null) data['imageUrl'] = imageUrl;

      final response =
          await _dioClient.dio.put('/flyers/items/$itemId', data: data);
      final item = FlyerItemModel.fromJson(response.data);
      return ApiResponse.success(item);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete flyer item
  Future<ApiResponse<bool>> deleteFlyerItem(String itemId) async {
    try {
      await _dioClient.dio.delete('/flyers/items/$itemId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get items for a specific flyer
  Future<ApiResponse<List<FlyerItemModel>>> getFlyerItems(
      String flyerId) async {
    try {
      final response = await _dioClient.dio.get('/flyers/$flyerId/items');
      final items = (response.data['items'] as List)
          .map((item) => FlyerItemModel.fromJson(item))
          .toList();
      return ApiResponse.success(items);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH FLYERS ==========

  /// Search flyers with query
  Future<ApiResponse<List<FlyerModel>>> searchFlyers({
    required String query,
    String? storeId,
    String? categoryId,
    bool activeOnly = true,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'search': query,
        'limit': limit,
        'offset': offset,
      };

      if (storeId != null) queryParams['storeId'] = storeId;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (activeOnly) queryParams['isActive'] = 'true';

      final response = await _dioClient.dio.get(
        '/flyers/search',
        queryParameters: queryParams,
      );

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== FLYER STATISTICS ==========

  /// Get flyer statistics (views, saves, etc.)
  Future<ApiResponse<Map<String, dynamic>>> getFlyerStats(
      String flyerId) async {
    try {
      final response = await _dioClient.dio.get('/flyers/$flyerId/stats');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store's flyer performance
  Future<ApiResponse<Map<String, dynamic>>> getStoreFlyerPerformance(
      String storeId) async {
    try {
      final response =
          await _dioClient.dio.get('/stores/$storeId/flyers/stats');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== FLYER SHARING ==========

  /// Generate shareable link for flyer
  Future<ApiResponse<String>> generateShareLink(String flyerId) async {
    try {
      final response = await _dioClient.dio.post('/flyers/$flyerId/share');
      final shareLink = response.data['shareLink'] as String;
      return ApiResponse.success(shareLink);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Track flyer share
  Future<ApiResponse<bool>> trackFlyerShare({
    required String flyerId,
    required String
        platform, // 'facebook', 'twitter', 'whatsapp', 'email', etc.
    String? userId,
  }) async {
    try {
      await _dioClient.dio.post('/flyers/$flyerId/track-share', data: {
        'platform': platform,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== FLYER RECOMMENDATIONS ==========

  /// Get personalized flyer recommendations for user
  Future<ApiResponse<List<FlyerModel>>> getRecommendedFlyers({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
          '/flyers/recommendations/$userId',
          queryParameters: {'limit': limit});

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get similar flyers based on current flyer
  Future<ApiResponse<List<FlyerModel>>> getSimilarFlyers({
    required String flyerId,
    int limit = 5,
  }) async {
    try {
      final response = await _dioClient.dio
          .get('/flyers/$flyerId/similar', queryParameters: {'limit': limit});

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== FLYER BULK OPERATIONS ==========

  /// Bulk delete flyers
  Future<ApiResponse<bool>> bulkDeleteFlyers(List<String> flyerIds) async {
    try {
      await _dioClient.dio.post('/flyers/bulk-delete', data: {
        'flyerIds': flyerIds,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Bulk update flyer status
  Future<ApiResponse<bool>> bulkUpdateFlyerStatus({
    required List<String> flyerIds,
    required bool isActive,
  }) async {
    try {
      await _dioClient.dio.post('/flyers/bulk-update-status', data: {
        'flyerIds': flyerIds,
        'isActive': isActive,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== UTILITY METHODS ==========

  /// Upload flyer image
  Future<ApiResponse<String>> uploadFlyerImage({
    required String filePath,
    required String fileName,
    String? flyerId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'folder': 'flyers',
        'flyerId': flyerId,
      });

      final response = await _dioClient.dio.post(
        '/upload/flyer-image',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final imageUrl = response.data['imageUrl'] as String;
      return ApiResponse.success(imageUrl);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Track flyer view for analytics
  Future<void> _trackFlyerView(String flyerId, String userId) async {
    try {
      await _dioClient.dio.post('/analytics/track', data: {
        'userId': userId,
        'action': 'VIEW_FLYER',
        'entityId': flyerId,
        'entityType': 'flyer',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail analytics tracking
      print('Analytics tracking failed: $e');
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
              return data?['message'] ??
                  'Invalid flyer data. Please check your input.';
            case 401:
              return 'Authentication failed. Please login again.';
            case 403:
              return 'Access denied. You don\'t have permission to access this flyer.';
            case 404:
              return data?['message'] ?? 'Flyer not found.';
            case 409:
              return data?['message'] ?? 'Flyer already exists.';
            case 422:
              return data?['message'] ??
                  'Invalid flyer data. Please check your input.';
            case 429:
              return 'Too many requests. Please try again later.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return data?['message'] ?? 'Failed to process flyer request.';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'Network error. Please check your internet connection.';
          }
          return 'Network error. Please check your connection.';
        default:
          return 'Something went wrong with flyer service.';
      }
    }
    return 'Flyer service error: ${error.toString()}';
  }
}
