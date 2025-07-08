// lib/services/search_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // ========== UNIVERSAL SEARCH ==========

  /// Universal search across all content types
  Future<ApiResponse<SearchResultsModel>> searchAll({
    required String query,
    String? categoryId,
    String? storeId,
    double? minDiscount,
    double? maxDistance,
    double? latitude,
    double? longitude,
    bool showExpiring = false,
    List<String> contentTypes = const ['flyers', 'coupons', 'stores'],
    String sortBy =
        'relevance', // 'relevance', 'distance', 'discount', 'expiry', 'popularity'
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
        'contentTypes': contentTypes.join(','),
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (storeId != null) queryParams['storeId'] = storeId;
      if (minDiscount != null) queryParams['minDiscount'] = minDiscount;
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (showExpiring) queryParams['showExpiring'] = showExpiring;

      final response = await _dioClient.dio.get(
        '/search/all',
        queryParameters: queryParams,
      );

      final searchResults = SearchResultsModel.fromJson(response.data);

      // Save search query for history
      await _saveSearchQuery(query);

      // Track search analytics
      await _trackSearch(query, searchResults.totalResults);

      return ApiResponse.success(searchResults);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search deals only (flyers + coupons)
  Future<ApiResponse<SearchResultsModel>> searchDeals({
    required String query,
    String? categoryId,
    String? storeId,
    double? minDiscount,
    double? maxDistance,
    double? latitude,
    double? longitude,
    bool showExpiring = false,
    List<String> dealTypes = const ['flyers', 'coupons'],
    String sortBy = 'relevance',
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await searchAll(
        query: query,
        categoryId: categoryId,
        storeId: storeId,
        minDiscount: minDiscount,
        maxDistance: maxDistance,
        latitude: latitude,
        longitude: longitude,
        showExpiring: showExpiring,
        contentTypes: dealTypes,
        sortBy: sortBy,
        limit: limit,
        page: page,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SPECIFIC CONTENT SEARCH ==========

  /// Search flyers specifically
  Future<ApiResponse<List<FlyerModel>>> searchFlyers({
    required String query,
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    double? maxDistance,
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
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance;
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

  /// Search coupons specifically
  Future<ApiResponse<List<CouponModel>>> searchCoupons({
    required String query,
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    double? maxDistance,
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
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance;
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

  /// Search stores specifically
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

  // ========== ADVANCED SEARCH ==========

  /// Advanced search with multiple filters
  Future<ApiResponse<SearchResultsModel>> advancedSearch({
    String? query,
    SearchFilters? filters,
    SearchSort? sort,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      // Apply filters
      if (filters != null) {
        if (filters.categoryIds.isNotEmpty) {
          queryParams['categoryIds'] = filters.categoryIds.join(',');
        }
        if (filters.storeIds.isNotEmpty) {
          queryParams['storeIds'] = filters.storeIds.join(',');
        }
        if (filters.minDiscount != null) {
          queryParams['minDiscount'] = filters.minDiscount;
        }
        if (filters.maxDiscount != null) {
          queryParams['maxDiscount'] = filters.maxDiscount;
        }
        if (filters.minPrice != null) {
          queryParams['minPrice'] = filters.minPrice;
        }
        if (filters.maxPrice != null) {
          queryParams['maxPrice'] = filters.maxPrice;
        }
        if (filters.maxDistance != null) {
          queryParams['maxDistance'] = filters.maxDistance;
        }
        if (filters.latitude != null) {
          queryParams['latitude'] = filters.latitude;
        }
        if (filters.longitude != null) {
          queryParams['longitude'] = filters.longitude;
        }
        if (filters.startDate != null) {
          queryParams['startDate'] = filters.startDate!.toIso8601String();
        }
        if (filters.endDate != null) {
          queryParams['endDate'] = filters.endDate!.toIso8601String();
        }
        if (filters.contentTypes.isNotEmpty) {
          queryParams['contentTypes'] = filters.contentTypes.join(',');
        }
        if (filters.isOnline != null) {
          queryParams['isOnline'] = filters.isOnline;
        }
        if (filters.isInStore != null) {
          queryParams['isInStore'] = filters.isInStore;
        }
        if (filters.isActive != null) {
          queryParams['isActive'] = filters.isActive;
        }
        if (filters.isSponsored != null) {
          queryParams['isSponsored'] = filters.isSponsored;
        }
        if (filters.showExpiring) {
          queryParams['showExpiring'] = filters.showExpiring;
        }
        if (filters.openNow) {
          queryParams['openNow'] = filters.openNow;
        }
      }

      // Apply sorting
      if (sort != null) {
        queryParams['sortBy'] = sort.field;
        queryParams['sortOrder'] = sort.order.name;
      }

      final response = await _dioClient.dio.get(
        '/search/advanced',
        queryParameters: queryParams,
      );

      final searchResults = SearchResultsModel.fromJson(response.data);

      if (query != null && query.isNotEmpty) {
        await _saveSearchQuery(query);
        await _trackSearch(query, searchResults.totalResults);
      }

      return ApiResponse.success(searchResults);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search with filters object
  Future<ApiResponse<SearchResultsModel>> searchWithFilters({
    required String query,
    required SearchFilters filters,
    String sortBy = 'relevance',
    int limit = 20,
    int page = 1,
  }) async {
    final sort = SearchSort(
      field: sortBy,
      order: SortOrder.desc,
    );

    return await advancedSearch(
      query: query,
      filters: filters,
      sort: sort,
      limit: limit,
      page: page,
    );
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

      final suggestions = List<String>.from(response.data['suggestions']);
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

      final searches = List<String>.from(response.data['searches']);
      return ApiResponse.success(searches);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get trending searches
  Future<ApiResponse<List<TrendingSearch>>> getTrendingSearches({
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

      final trending = (response.data['trending'] as List)
          .map((item) => TrendingSearch.fromJson(item))
          .toList();

      return ApiResponse.success(trending);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get personalized search suggestions
  Future<ApiResponse<List<String>>> getPersonalizedSuggestions({
    required String query,
    String? userId,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'limit': limit,
      };

      if (userId != null) queryParams['userId'] = userId;

      final response = await _dioClient.dio.get(
        '/search/personalized-suggestions',
        queryParameters: queryParams,
      );

      final suggestions = List<String>.from(response.data['suggestions']);
      return ApiResponse.success(suggestions);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH HISTORY ==========

  /// Get user's search history
  Future<ApiResponse<List<SearchHistoryItem>>> getSearchHistory({
    int limit = 50,
    int page = 1,
  }) async {
    try {
      // Get from local storage first
      final localHistory = await StorageService.getSearchHistory();

      // Also try to get from server if user is logged in
      try {
        final response = await _dioClient.dio.get('/search/history',
            queryParameters: {'limit': limit, 'page': page});

        final serverHistory = (response.data['history'] as List)
            .map((item) => SearchHistoryItem.fromJson(item))
            .toList();

        // Merge local and server history
        final mergedHistory = _mergeSearchHistory(localHistory, serverHistory);
        return ApiResponse.success(mergedHistory);
      } catch (e) {
        // If server request fails, return local history
        return ApiResponse.success(localHistory);
      }
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Clear search history
  Future<ApiResponse<bool>> clearSearchHistory() async {
    try {
      // Clear local storage
      await StorageService.clearSearchHistory();

      // Try to clear server history if user is logged in
      try {
        await _dioClient.dio.delete('/search/history');
      } catch (e) {
        // Ignore server errors, local clear is sufficient
      }

      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Remove specific search from history
  Future<ApiResponse<bool>> removeFromSearchHistory(String query) async {
    try {
      await StorageService.removeFromSearchHistory(query);

      try {
        await _dioClient.dio.delete('/search/history/$query');
      } catch (e) {
        // Ignore server errors
      }

      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH FILTERS ==========

  /// Get available search filters
  Future<ApiResponse<AvailableFilters>> getAvailableFilters({
    String? query,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (query != null) queryParams['q'] = query;
      if (category != null) queryParams['category'] = category;

      final response = await _dioClient.dio.get(
        '/search/filters',
        queryParameters: queryParams,
      );

      final filters = AvailableFilters.fromJson(response.data);
      return ApiResponse.success(filters);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get filter suggestions based on current search
  Future<ApiResponse<FilterSuggestions>> getFilterSuggestions({
    required String query,
    SearchFilters? currentFilters,
  }) async {
    try {
      final data = <String, dynamic>{
        'query': query,
      };

      if (currentFilters != null) {
        data['currentFilters'] = currentFilters.toJson();
      }

      final response = await _dioClient.dio.post(
        '/search/filter-suggestions',
        data: data,
      );

      final suggestions = FilterSuggestions.fromJson(response.data);
      return ApiResponse.success(suggestions);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SAVED SEARCHES ==========

  /// Save a search query with filters
  Future<ApiResponse<bool>> saveSearch({
    required String name,
    required String query,
    SearchFilters? filters,
    bool enableNotifications = false,
  }) async {
    try {
      await _dioClient.dio.post('/search/save', data: {
        'name': name,
        'query': query,
        'filters': filters?.toJson(),
        'enableNotifications': enableNotifications,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get saved searches
  Future<ApiResponse<List<SavedSearch>>> getSavedSearches() async {
    try {
      final response = await _dioClient.dio.get('/search/saved');

      final savedSearches = (response.data['savedSearches'] as List)
          .map((item) => SavedSearch.fromJson(item))
          .toList();

      return ApiResponse.success(savedSearches);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete saved search
  Future<ApiResponse<bool>> deleteSavedSearch(String savedSearchId) async {
    try {
      await _dioClient.dio.delete('/search/saved/$savedSearchId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Execute saved search
  Future<ApiResponse<SearchResultsModel>> executeSavedSearch(
      String savedSearchId) async {
    try {
      final response =
          await _dioClient.dio.post('/search/saved/$savedSearchId/execute');

      final searchResults = SearchResultsModel.fromJson(response.data);
      return ApiResponse.success(searchResults);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH ANALYTICS ==========

  /// Get search analytics for user
  Future<ApiResponse<SearchAnalytics>> getSearchAnalytics({
    String? timeframe = 'month',
  }) async {
    try {
      final response = await _dioClient.dio
          .get('/search/analytics', queryParameters: {'timeframe': timeframe});

      final analytics = SearchAnalytics.fromJson(response.data);
      return ApiResponse.success(analytics);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Track search interaction
  Future<ApiResponse<bool>> trackSearchInteraction({
    required String query,
    required String action, // 'click', 'save', 'share', 'view_more'
    String? itemId,
    String? itemType,
    int? position,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dioClient.dio.post('/search/track-interaction', data: {
        'query': query,
        'action': action,
        'itemId': itemId,
        'itemType': itemType,
        'position': position,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return ApiResponse.success(true);
    } catch (e) {
      // Don't fail on analytics errors
      return ApiResponse.success(true);
    }
  }

  // ========== UTILITY METHODS ==========

  /// Save search query to history
  Future<void> _saveSearchQuery(String query) async {
    try {
      await StorageService.addToSearchHistory(query);

      // Also save to server if user is logged in
      try {
        await _dioClient.dio.post('/search/history', data: {
          'query': query,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Ignore server errors for history
      }
    } catch (e) {
      // Ignore history save errors
    }
  }

  /// Track search for analytics
  Future<void> _trackSearch(String query, int resultCount) async {
    try {
      await _dioClient.dio.post('/analytics/search', data: {
        'query': query,
        'resultCount': resultCount,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore analytics errors
    }
  }

  /// Merge local and server search history
  List<SearchHistoryItem> _mergeSearchHistory(
    List<SearchHistoryItem> local,
    List<SearchHistoryItem> server,
  ) {
    final merged = <String, SearchHistoryItem>{};

    // Add server items first (they have more metadata)
    for (final item in server) {
      merged[item.query] = item;
    }

    // Add local items if not already present
    for (final item in local) {
      if (!merged.containsKey(item.query)) {
        merged[item.query] = item;
      }
    }

    // Return sorted by timestamp (newest first)
    final result = merged.values.toList();
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return result;
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
