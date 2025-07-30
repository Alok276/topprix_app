// lib/services/search_service.dart - NEW SIMPLIFIED VERSION
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/models/search_result_model.dart';
import '../models/flyer_model.dart';
import '../models/coupon_model.dart';
import '../models/store_model.dart';
import '../models/api_response.dart';
import 'dio_client.dart';
import 'storage_service.dart';

final searchServiceProvider = Provider((ref) => SearchService());

class SearchService {
  final DioClient _dioClient;

  SearchService() : _dioClient = DioClient();

  // ========== BASIC SEARCH ==========

  /// Universal search across all content types
  Future<ApiResponse<SearchResultsModel>> searchAll({
    required String query,
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    double? maxDistance,
    String sortBy = 'relevance', // 'relevance', 'distance', 'discount', 'date'
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (storeId != null) queryParams['storeId'] = storeId;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance;

      final response = await _dioClient.dio.get(
        '/search/all',
        queryParameters: queryParams,
      );

      final searchResults = SearchResultsModel.fromJson(response.data);

      // Save search query for history
      await _saveSearchQuery(query);

      return ApiResponse.success(searchResults);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ADD THIS METHOD TO YOUR EXISTING SearchService CLASS
// Place it after the searchAll method

  /// Search deals only (flyers + coupons)
  Future<ApiResponse<Map<String, dynamic>>> searchDeals({
    required String query,
    String? categoryId,
    String? storeId,
    double? minDiscount,
    double? maxDistance,
    double? latitude,
    double? longitude,
    bool showExpiring = false,
    List<String>? dealTypes,
    String sortBy = 'relevance',
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (storeId != null) queryParams['storeId'] = storeId;
      if (minDiscount != null) queryParams['minDiscount'] = minDiscount;
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (showExpiring) queryParams['showExpiring'] = showExpiring;
      if (dealTypes != null && dealTypes.isNotEmpty) {
        queryParams['dealTypes'] = dealTypes.join(',');
      }

      final response = await _dioClient.dio.get(
        '/search/deals',
        queryParameters: queryParams,
      );

      // Save search query for history
      await _saveSearchQuery(query);

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search flyers only
  Future<ApiResponse<List<FlyerModel>>> searchFlyers({
    required String query,
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    bool activeOnly = true,
    String sortBy = 'relevance',
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (storeId != null) queryParams['storeId'] = storeId;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (activeOnly) queryParams['activeOnly'] = activeOnly;

      final response = await _dioClient.dio.get(
        '/search/flyers',
        queryParameters: queryParams,
      );

      final flyers = (response.data['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList();

      await _saveSearchQuery(query);
      return ApiResponse.success(flyers);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search coupons only
  Future<ApiResponse<List<CouponModel>>> searchCoupons({
    required String query,
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    bool? isOnline,
    bool? isInStore,
    bool activeOnly = true,
    String sortBy = 'relevance',
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (storeId != null) queryParams['storeId'] = storeId;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (isOnline != null) queryParams['isOnline'] = isOnline;
      if (isInStore != null) queryParams['isInStore'] = isInStore;
      if (activeOnly) queryParams['activeOnly'] = activeOnly;

      final response = await _dioClient.dio.get(
        '/search/coupons',
        queryParameters: queryParams,
      );

      final coupons = (response.data['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList();

      await _saveSearchQuery(query);
      return ApiResponse.success(coupons);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search stores only
  Future<ApiResponse<List<StoreModel>>> searchStores({
    required String query,
    String? categoryId,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    double? maxDistance,
    bool openNow = false,
    String sortBy = 'relevance',
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (city != null) queryParams['city'] = city;
      if (state != null) queryParams['state'] = state;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance;
      if (openNow) queryParams['openNow'] = openNow;

      final response = await _dioClient.dio.get(
        '/search/stores',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      await _saveSearchQuery(query);
      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH SUGGESTIONS ==========

  /// Get search suggestions/autocomplete
  Future<ApiResponse<List<String>>> getSearchSuggestions({
    required String query,
    int limit = 10,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;

      final response = await _dioClient.dio.get(
        '/search/suggestions',
        queryParameters: queryParams,
      );

      final suggestions = List<String>.from(response.data['suggestions'] ?? []);
      return ApiResponse.success(suggestions);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get popular searches
  Future<ApiResponse<List<String>>> getPopularSearches({
    int limit = 10,
    String? category,
    String? timeframe = 'week', // 'day', 'week', 'month', 'all'
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'timeframe': timeframe,
      };

      if (category != null) queryParams['category'] = category;

      final response = await _dioClient.dio.get(
        '/search/popular',
        queryParameters: queryParams,
      );

      final searches = List<String>.from(response.data['searches'] ?? []);
      return ApiResponse.success(searches);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get trending searches
  Future<ApiResponse<List<String>>> getTrendingSearches({
    int limit = 10,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;

      final response = await _dioClient.dio.get(
        '/search/trending',
        queryParameters: queryParams,
      );

      final trending = List<String>.from(response.data['trending'] ?? []);
      return ApiResponse.success(trending);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH HISTORY ==========

  /// Get user's search history from local storage
  Future<ApiResponse<List<SearchHistoryItem>>> getSearchHistory({
    int limit = 50,
  }) async {
    try {
      final localHistory = await StorageService.getSearchHistory();

      // Limit the results
      final limitedHistory = localHistory.take(limit).toList();

      return ApiResponse.success(limitedHistory);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get recent search queries (simple strings)
  Future<ApiResponse<List<String>>> getRecentSearches({
    int limit = 10,
  }) async {
    try {
      final recentSearches = await StorageService.getRecentSearches();

      // Limit the results
      final limitedSearches = recentSearches.take(limit).toList();

      return ApiResponse.success(limitedSearches);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Clear search history
  Future<ApiResponse<bool>> clearSearchHistory() async {
    try {
      await StorageService.clearSearchHistory();
      await StorageService.clearRecentSearches();
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Remove specific search from history
  Future<ApiResponse<bool>> removeFromSearchHistory(String query) async {
    try {
      await StorageService.removeFromSearchHistory(query);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SIMPLE FILTERS ==========

  /// Search with basic filters
  Future<ApiResponse<SearchResultsModel>> searchWithBasicFilters({
    required String query,
    BasicSearchFilters? filters,
    String sortBy = 'relevance',
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
      };

      if (filters != null) {
        if (filters.categoryId != null)
          queryParams['categoryId'] = filters.categoryId;
        if (filters.storeId != null) queryParams['storeId'] = filters.storeId;
        if (filters.minDiscount != null)
          queryParams['minDiscount'] = filters.minDiscount;
        if (filters.maxDistance != null)
          queryParams['maxDistance'] = filters.maxDistance;
        if (filters.latitude != null)
          queryParams['latitude'] = filters.latitude;
        if (filters.longitude != null)
          queryParams['longitude'] = filters.longitude;
        if (filters.isOnline != null)
          queryParams['isOnline'] = filters.isOnline;
        if (filters.isInStore != null)
          queryParams['isInStore'] = filters.isInStore;
        if (filters.activeOnly != null)
          queryParams['activeOnly'] = filters.activeOnly;
        if (filters.dealTypes != null && filters.dealTypes!.isNotEmpty) {
          queryParams['dealTypes'] = filters.dealTypes!.join(',');
        }
      }

      final response = await _dioClient.dio.get(
        '/search/filtered',
        queryParameters: queryParams,
      );

      final searchResults = SearchResultsModel.fromJson(response.data);
      await _saveSearchQuery(query);

      return ApiResponse.success(searchResults);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH ANALYTICS ==========

  /// Track search interaction for analytics
  Future<ApiResponse<bool>> trackSearchInteraction({
    required String query,
    required String action, // 'click', 'view', 'save', 'share'
    String? itemId,
    String? itemType,
    int? position,
  }) async {
    try {
      await _dioClient.dio.post('/search/track', data: {
        'query': query,
        'action': action,
        'itemId': itemId,
        'itemType': itemType,
        'position': position,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return ApiResponse.success(true);
    } catch (e) {
      // Don't fail on analytics errors
      return ApiResponse.success(true);
    }
  }

  // ========== UTILITY METHODS ==========

  /// Save search query to local storage
  Future<void> _saveSearchQuery(String query) async {
    try {
      // Add to detailed search history
      await StorageService.addToSearchHistory(query);

      // Add to simple recent searches
      await StorageService.addRecentSearch(query);
    } catch (e) {
      print('Error saving search query: $e');
      // Don't throw error, just log it
    }
  }

  /// Validate search query
  bool isValidQuery(String query) {
    return query.trim().length >= 2;
  }

  /// Clean search query
  String cleanQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// Extract keywords from query
  List<String> extractKeywords(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .toList();
  }

  // ========== ERROR HANDLING ==========

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Search timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          switch (statusCode) {
            case 400:
              return data?['message'] ??
                  'Invalid search query. Please try different keywords.';
            case 401:
              return 'Authentication failed. Please login again.';
            case 404:
              return 'Search service not available.';
            case 429:
              return 'Too many search requests. Please try again later.';
            case 500:
              return 'Search service error. Please try again later.';
            default:
              return data?['message'] ?? 'Search failed. Please try again.';
          }
        case DioExceptionType.cancel:
          return 'Search was cancelled.';
        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'Network error. Please check your internet connection.';
          }
          return 'Network error. Please check your connection.';
        default:
          return 'Search error. Please try again.';
      }
    }
    return 'Search error: ${error.toString()}';
  }
}

// ========== SIMPLE FILTER MODEL ==========

class BasicSearchFilters {
  final String? categoryId;
  final String? storeId;
  final double? minDiscount;
  final double? maxDistance;
  final double? latitude;
  final double? longitude;
  final bool? isOnline;
  final bool? isInStore;
  final bool? activeOnly;
  final List<String>? dealTypes; // ['flyer', 'coupon']

  BasicSearchFilters({
    this.categoryId,
    this.storeId,
    this.minDiscount,
    this.maxDistance,
    this.latitude,
    this.longitude,
    this.isOnline,
    this.isInStore,
    this.activeOnly,
    this.dealTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'storeId': storeId,
      'minDiscount': minDiscount,
      'maxDistance': maxDistance,
      'latitude': latitude,
      'longitude': longitude,
      'isOnline': isOnline,
      'isInStore': isInStore,
      'activeOnly': activeOnly,
      'dealTypes': dealTypes,
    };
  }

  factory BasicSearchFilters.fromJson(Map<String, dynamic> json) {
    return BasicSearchFilters(
      categoryId: json['categoryId'],
      storeId: json['storeId'],
      minDiscount: json['minDiscount']?.toDouble(),
      maxDistance: json['maxDistance']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isOnline: json['isOnline'],
      isInStore: json['isInStore'],
      activeOnly: json['activeOnly'],
      dealTypes: json['dealTypes'] != null
          ? List<String>.from(json['dealTypes'])
          : null,
    );
  }

  BasicSearchFilters copyWith({
    String? categoryId,
    String? storeId,
    double? minDiscount,
    double? maxDistance,
    double? latitude,
    double? longitude,
    bool? isOnline,
    bool? isInStore,
    bool? activeOnly,
    List<String>? dealTypes,
  }) {
    return BasicSearchFilters(
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      minDiscount: minDiscount ?? this.minDiscount,
      maxDistance: maxDistance ?? this.maxDistance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnline: isOnline ?? this.isOnline,
      isInStore: isInStore ?? this.isInStore,
      activeOnly: activeOnly ?? this.activeOnly,
      dealTypes: dealTypes ?? this.dealTypes,
    );
  }
}
