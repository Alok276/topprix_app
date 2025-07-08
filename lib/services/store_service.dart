// lib/services/store_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_model.dart';
import '../models/flyer_model.dart';
import '../models/coupon_model.dart';
import '../models/api_response.dart';
import 'dio_client.dart';
import 'dart:math' as math;

final storeServiceProvider = Provider((ref) => StoreService());

class StoreService {
  final DioClient _dioClient;

  StoreService() : _dioClient = DioClient();

  // ========== GET STORES ==========

  /// Get all stores with optional filters
  Future<ApiResponse<List<StoreModel>>> getStores({
    String? search,
    String? city,
    String? state,
    String? country,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    bool openNow = false,
    String sortBy = 'name', // 'name', 'distance', 'rating', 'popularity'
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'sortBy': sortBy,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (city != null) queryParams['city'] = city;
      if (state != null) queryParams['state'] = state;
      if (country != null) queryParams['country'] = country;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (openNow) queryParams['openNow'] = openNow.toString();

      final response = await _dioClient.dio.get(
        '/stores',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get stores with advanced filters
  Future<ApiResponse<List<StoreModel>>> getStoresWithFilters({
    String? search,
    String? city,
    String? state,
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
    List<String>? amenities,
    bool openNow = false,
    double? minRating,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (search != null) queryParams['search'] = search;
      if (city != null) queryParams['city'] = city;
      if (state != null) queryParams['state'] = state;
      if (category != null) queryParams['category'] = category;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;
      if (amenities != null) queryParams['amenities'] = amenities.join(',');
      if (openNow) queryParams['openNow'] = openNow.toString();
      if (minRating != null) queryParams['minRating'] = minRating;

      final response = await _dioClient.dio.get(
        '/stores/filters',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get featured/popular stores
  Future<ApiResponse<List<StoreModel>>> getFeaturedStores({
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'featured': 'true',
      };

      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;

      final response = await _dioClient.dio.get(
        '/stores',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get nearby stores
  Future<ApiResponse<List<StoreModel>>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    String? categoryId,
    bool openNow = false,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'limit': limit,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId as num;
      if (openNow) queryParams['openNow'] = openNow.toString() as num;

      final response = await _dioClient.dio.get(
        '/location/nearby-stores',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get stores by category
  Future<ApiResponse<List<StoreModel>>> getStoresByCategory({
    required String categoryId,
    double? latitude,
    double? longitude,
    String? city,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await getStores(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        city: city,
        limit: limit,
        offset: offset,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SINGLE STORE OPERATIONS ==========

  /// Get store by ID
  Future<ApiResponse<StoreModel>> getStoreById(String storeId) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId');
      final store = StoreModel.fromJson(response.data);
      return ApiResponse.success(store);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store details with analytics tracking
  Future<ApiResponse<StoreModel>> getStoreDetail(
    String storeId, {
    String? userId,
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId');
      final store = StoreModel.fromJson(response.data);

      // Track store view analytics if userId provided
      if (userId != null) {
        _trackStoreView(storeId, userId, userLatitude, userLongitude);
      }

      return ApiResponse.success(store);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store with current deals count
  Future<ApiResponse<StoreWithDealsModel>> getStoreWithDeals(
      String storeId) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId/with-deals');
      final storeWithDeals = StoreWithDealsModel.fromJson(response.data);
      return ApiResponse.success(storeWithDeals);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE CONTENT ==========

  /// Get flyers for a specific store
  Future<ApiResponse<List<FlyerModel>>> getStoreFlyers({
    required String storeId,
    bool activeOnly = true,
    String? categoryId,
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
      if (categoryId != null) queryParams['categoryId'] = categoryId;

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

  /// Get coupons for a specific store
  Future<ApiResponse<List<CouponModel>>> getStoreCoupons({
    required String storeId,
    bool activeOnly = true,
    String? categoryId,
    bool? isOnline,
    bool? isInStore,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'storeId': storeId,
        'limit': limit,
        'page': page,
      };

      if (activeOnly) queryParams['active'] = 'true';
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isOnline != null) queryParams['isOnline'] = isOnline.toString();
      if (isInStore != null) queryParams['isInStore'] = isInStore.toString();

      final response = await _dioClient.dio.get(
        '/coupons',
        queryParameters: queryParams,
      );

      final coupons = (response.data['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList();

      return ApiResponse.success(coupons);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get all deals for a store (flyers + coupons)
  Future<ApiResponse<StoreDealsModel>> getStoreDeals({
    required String storeId,
    bool activeOnly = true,
    String? categoryId,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'storeId': storeId,
        'limit': limit,
      };

      if (activeOnly) queryParams['activeOnly'] = activeOnly.toString();
      if (categoryId != null) queryParams['categoryId'] = categoryId;

      final response = await _dioClient.dio.get(
        '/stores/$storeId/deals',
        queryParameters: queryParams,
      );

      final storeDeals = StoreDealsModel.fromJson(response.data);
      return ApiResponse.success(storeDeals);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE SEARCH ==========

  /// Search stores by name or description
  Future<ApiResponse<List<StoreModel>>> searchStores(
    String query, {
    String? city,
    String? state,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? maxDistance,
    bool openNow = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await getStores(
        search: query,
        city: city,
        state: state,
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        radius: maxDistance,
        openNow: openNow,
        limit: limit,
        offset: offset,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search stores by location and query
  Future<ApiResponse<List<StoreModel>>> searchStoresByLocation({
    required String query,
    required double latitude,
    required double longitude,
    double radius = 25.0,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'limit': limit,
      };

      final response = await _dioClient.dio.get(
        '/location/search-stores',
        queryParameters: queryParams,
      );

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE MANAGEMENT (Admin/Retailer) ==========

  /// Create a new store
  Future<ApiResponse<StoreModel>> createStore({
    required String name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    String? imageUrl,
    Map<String, String>? openingHours,
    List<String>? amenities,
    List<String>? categoryIds,
  }) async {
    try {
      final response = await _dioClient.dio.post('/stores', data: {
        'name': name,
        'description': description,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'email': email,
        'website': website,
        'logoUrl': logoUrl,
        'imageUrl': imageUrl,
        'openingHours': openingHours,
        'amenities': amenities,
        'categoryIds': categoryIds,
      });

      final store = StoreModel.fromJson(response.data);
      return ApiResponse.success(store);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Update existing store
  Future<ApiResponse<StoreModel>> updateStore({
    required String storeId,
    String? name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    String? imageUrl,
    Map<String, String>? openingHours,
    List<String>? amenities,
    List<String>? categoryIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (country != null) data['country'] = country;
      if (postalCode != null) data['postalCode'] = postalCode;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (website != null) data['website'] = website;
      if (logoUrl != null) data['logoUrl'] = logoUrl;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      if (openingHours != null) data['openingHours'] = openingHours;
      if (amenities != null) data['amenities'] = amenities;
      if (categoryIds != null) data['categoryIds'] = categoryIds;

      final response = await _dioClient.dio.put('/stores/$storeId', data: data);
      final store = StoreModel.fromJson(response.data);
      return ApiResponse.success(store);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete a store
  Future<ApiResponse<bool>> deleteStore(String storeId) async {
    try {
      await _dioClient.dio.delete('/stores/$storeId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE HOURS & STATUS ==========

  /// Check if store is currently open
  Future<ApiResponse<bool>> isStoreOpen(String storeId) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId/is-open');
      final isOpen = response.data['isOpen'] as bool;
      return ApiResponse.success(isOpen);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store opening hours
  Future<ApiResponse<Map<String, String>>> getStoreHours(String storeId) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId/hours');
      final hours = Map<String, String>.from(response.data['hours']);
      return ApiResponse.success(hours);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Update store opening hours
  Future<ApiResponse<bool>> updateStoreHours({
    required String storeId,
    required Map<String, String> openingHours,
  }) async {
    try {
      await _dioClient.dio.put('/stores/$storeId/hours', data: {
        'openingHours': openingHours,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store holiday hours
  Future<ApiResponse<List<HolidayHours>>> getStoreHolidayHours(
      String storeId) async {
    try {
      final response =
          await _dioClient.dio.get('/stores/$storeId/holiday-hours');
      final holidayHours = (response.data['holidayHours'] as List)
          .map((item) => HolidayHours.fromJson(item))
          .toList();
      return ApiResponse.success(holidayHours);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE REVIEWS & RATINGS ==========

  /// Get store reviews
  Future<ApiResponse<StoreReviewsModel>> getStoreReviews({
    required String storeId,
    int limit = 20,
    int page = 1,
    String sortBy = 'newest', // 'newest', 'oldest', 'rating_high', 'rating_low'
  }) async {
    try {
      final response = await _dioClient.dio
          .get('/stores/$storeId/reviews', queryParameters: {
        'limit': limit,
        'page': page,
        'sortBy': sortBy,
      });

      final reviews = StoreReviewsModel.fromJson(response.data);
      return ApiResponse.success(reviews);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Add store review
  Future<ApiResponse<bool>> addStoreReview({
    required String storeId,
    required int rating, // 1-5
    String? review,
    List<String>? photos,
  }) async {
    try {
      await _dioClient.dio.post('/stores/$storeId/reviews', data: {
        'rating': rating,
        'review': review,
        'photos': photos,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Update store review
  Future<ApiResponse<bool>> updateStoreReview({
    required String reviewId,
    int? rating,
    String? review,
    List<String>? photos,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (review != null) data['review'] = review;
      if (photos != null) data['photos'] = photos;

      await _dioClient.dio.put('/stores/reviews/$reviewId', data: data);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete store review
  Future<ApiResponse<bool>> deleteStoreReview(String reviewId) async {
    try {
      await _dioClient.dio.delete('/stores/reviews/$reviewId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store rating summary
  Future<ApiResponse<StoreRatingSummary>> getStoreRatingSummary(
      String storeId) async {
    try {
      final response =
          await _dioClient.dio.get('/stores/$storeId/rating-summary');
      final summary = StoreRatingSummary.fromJson(response.data);
      return ApiResponse.success(summary);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE FAVORITES ==========

  /// Add store to favorites
  Future<ApiResponse<bool>> addToFavorites(String storeId) async {
    try {
      await _dioClient.dio.post('/stores/$storeId/favorite');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Remove store from favorites
  Future<ApiResponse<bool>> removeFromFavorites(String storeId) async {
    try {
      await _dioClient.dio.delete('/stores/$storeId/favorite');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Check if store is in favorites
  Future<ApiResponse<bool>> isStoreInFavorites(String storeId) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId/is-favorite');
      final isFavorite = response.data['isFavorite'] as bool;
      return ApiResponse.success(isFavorite);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get user's favorite stores
  Future<ApiResponse<List<StoreModel>>> getFavoriteStores({
    double? latitude,
    double? longitude,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;

      final response = await _dioClient.dio
          .get('/stores/favorites', queryParameters: queryParams);

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE STATISTICS ==========

  /// Get store performance statistics
  Future<ApiResponse<StoreStatsModel>> getStoreStats(String storeId) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId/stats');
      final stats = StoreStatsModel.fromJson(response.data);
      return ApiResponse.success(stats);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store analytics (for store owners)
  Future<ApiResponse<StoreAnalyticsModel>> getStoreAnalytics({
    required String storeId,
    String timeframe = 'month', // 'week', 'month', 'quarter', 'year'
  }) async {
    try {
      final response = await _dioClient.dio.get('/stores/$storeId/analytics',
          queryParameters: {'timeframe': timeframe});

      final analytics = StoreAnalyticsModel.fromJson(response.data);
      return ApiResponse.success(analytics);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE DIRECTIONS & CONTACT ==========

  /// Get directions to store
  Future<ApiResponse<DirectionsModel>> getDirectionsToStore({
    required String storeId,
    required double userLatitude,
    required double userLongitude,
    String travelMode = 'driving', // 'driving', 'walking', 'transit'
  }) async {
    try {
      final response = await _dioClient.dio
          .get('/stores/$storeId/directions', queryParameters: {
        'userLat': userLatitude,
        'userLng': userLongitude,
        'travelMode': travelMode,
      });

      final directions = DirectionsModel.fromJson(response.data);
      return ApiResponse.success(directions);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Contact store (call, email, etc.)
  Future<ApiResponse<bool>> contactStore({
    required String storeId,
    required String contactType, // 'call', 'email', 'website'
    String? message,
  }) async {
    try {
      await _dioClient.dio.post('/stores/$storeId/contact', data: {
        'contactType': contactType,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Track contact analytics
      await _trackStoreContact(storeId, contactType);

      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== STORE NOTIFICATIONS ==========

  /// Subscribe to store notifications
  Future<ApiResponse<bool>> subscribeToStoreNotifications({
    required String storeId,
    List<String> notificationTypes = const [
      'new_deals',
      'price_drops',
      'new_flyers'
    ],
  }) async {
    try {
      await _dioClient.dio.post('/stores/$storeId/subscribe', data: {
        'notificationTypes': notificationTypes,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Unsubscribe from store notifications
  Future<ApiResponse<bool>> unsubscribeFromStoreNotifications(
      String storeId) async {
    try {
      await _dioClient.dio.delete('/stores/$storeId/subscribe');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Check subscription status
  Future<ApiResponse<bool>> isSubscribedToStore(String storeId) async {
    try {
      final response =
          await _dioClient.dio.get('/stores/$storeId/subscription-status');
      final isSubscribed = response.data['isSubscribed'] as bool;
      return ApiResponse.success(isSubscribed);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== BULK OPERATIONS ==========

  /// Get multiple stores by IDs
  Future<ApiResponse<List<StoreModel>>> getStoresByIds(
      List<String> storeIds) async {
    try {
      final response = await _dioClient.dio.post('/stores/bulk-get', data: {
        'storeIds': storeIds,
      });

      final stores = (response.data['stores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();

      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Bulk update store status
  Future<ApiResponse<bool>> bulkUpdateStoreStatus({
    required List<String> storeIds,
    required bool isActive,
  }) async {
    try {
      await _dioClient.dio.post('/stores/bulk-update-status', data: {
        'storeIds': storeIds,
        'isActive': isActive,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== UTILITY METHODS ==========

  /// Upload store image
  Future<ApiResponse<String>> uploadStoreImage({
    required String filePath,
    required String fileName,
    String? storeId,
    String imageType = 'logo', // 'logo', 'cover', 'gallery'
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'folder': 'stores',
        'storeId': storeId,
        'imageType': imageType,
      });

      final response = await _dioClient.dio.post(
        '/upload/store-image',
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

  /// Calculate distance to store
  Future<ApiResponse<double>> calculateDistanceToStore({
    required String storeId,
    required double userLatitude,
    required double userLongitude,
  }) async {
    try {
      final storeResponse = await getStoreById(storeId);
      if (!storeResponse.success) {
        return ApiResponse.error(storeResponse.error!);
      }

      final store = storeResponse.data!;
      if (store.latitude == null || store.longitude == null) {
        return ApiResponse.error('Store location not available.');
      }

      // Calculate distance using Haversine formula
      final distance = _calculateHaversineDistance(
        userLatitude,
        userLongitude,
        store.latitude!,
        store.longitude!,
      );

      return ApiResponse.success(distance);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Check store availability for deals
  Future<ApiResponse<bool>> checkStoreAvailability(String storeId) async {
    try {
      final response =
          await _dioClient.dio.get('/stores/$storeId/availability');
      final isAvailable = response.data['isAvailable'] as bool;
      return ApiResponse.success(isAvailable);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store categories
  Future<ApiResponse<List<String>>> getStoreCategories() async {
    try {
      final response = await _dioClient.dio.get('/stores/categories');
      final categories = List<String>.from(response.data['categories']);
      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store amenities list
  Future<ApiResponse<List<String>>> getStoreAmenities() async {
    try {
      final response = await _dioClient.dio.get('/stores/amenities');
      final amenities = List<String>.from(response.data['amenities']);
      return ApiResponse.success(amenities);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// ========== STORE SHARING ==========

  /// Generate shareable store link
  Future<ApiResponse<String>> generateStoreShareLink(String storeId) async {
    try {
      final response = await _dioClient.dio.post('/stores/$storeId/share');
      final shareLink = response.data['shareLink'] as String;
      return ApiResponse.success(shareLink);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Track store share
  Future<ApiResponse<bool>> trackStoreShare({
    required String storeId,
    required String platform, // 'facebook', 'twitter', 'whatsapp', 'email'
    String? userId,
  }) async {
    try {
      await _dioClient.dio.post('/stores/$storeId/track-share', data: {
        'platform': platform,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// ========== PRIVATE METHODS ==========

  /// Track store view for analytics
  Future<void> _trackStoreView(
    String storeId,
    String userId,
    double? latitude,
    double? longitude,
  ) async {
    try {
      await _dioClient.dio.post('/analytics/track', data: {
        'userId': userId,
        'action': 'VIEW_STORE',
        'entityId': storeId,
        'entityType': 'store',
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail analytics tracking
      print('Analytics tracking failed: $e');
    }
  }

  /// Track store contact for analytics
  Future<void> _trackStoreContact(String storeId, String contactType) async {
    try {
      await _dioClient.dio.post('/analytics/track', data: {
        'action': 'CONTACT_STORE',
        'entityId': storeId,
        'entityType': 'store',
        'metadata': {'contactType': contactType},
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail analytics tracking
    }
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Format store hours for display
  String formatStoreHours(Map<String, String> hours) {
    final today = DateTime.now().weekday;
    final dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    final todayName = dayNames[today - 1];

    if (hours.containsKey(todayName)) {
      return 'Today: ${hours[todayName]}';
    }

    return 'Hours not available';
  }

  /// Check if store is currently open based on hours
  bool isStoreCurrentlyOpen(Map<String, String> hours) {
    final now = DateTime.now();
    final today = now.weekday;
    final dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    final todayName = dayNames[today - 1];

    if (!hours.containsKey(todayName)) {
      return false;
    }

    final todayHours = hours[todayName]!;
    if (todayHours.toLowerCase() == 'closed') {
      return false;
    }

    // Parse hours (e.g., "9:00 AM - 9:00 PM")
    final hoursParts = todayHours.split(' - ');
    if (hoursParts.length != 2) {
      return false;
    }

    try {
      final openTime = _parseTime(hoursParts[0]);
      final closeTime = _parseTime(hoursParts[1]);
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      return _isTimeBetween(currentTime, openTime, closeTime);
    } catch (e) {
      return false;
    }
  }

  /// Parse time string to TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    final cleanTime = timeStr.trim();
    final isAM = cleanTime.toUpperCase().contains('AM');
    final isPM = cleanTime.toUpperCase().contains('PM');

    final timeOnly = cleanTime.replaceAll(RegExp(r'[AP]M'), '').trim();
    final parts = timeOnly.split(':');

    int hour = int.parse(parts[0]);
    int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    if (isPM && hour != 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Check if current time is between open and close times
  bool _isTimeBetween(TimeOfDay current, TimeOfDay open, TimeOfDay close) {
    final currentMinutes = current.hour * 60 + current.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    if (closeMinutes > openMinutes) {
      // Same day (e.g., 9 AM - 9 PM)
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    } else {
      // Crosses midnight (e.g., 10 PM - 2 AM)
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
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
                  'Invalid store data. Please check your input.';
            case 401:
              return 'Authentication failed. Please login again.';
            case 403:
              return 'Access denied. You don\'t have permission to access this store.';
            case 404:
              return data?['message'] ?? 'Store not found.';
            case 409:
              return data?['message'] ?? 'Store already exists.';
            case 422:
              return data?['message'] ??
                  'Invalid store data. Please check your input.';
            case 429:
              return 'Too many requests. Please try again later.';
            case 500:
              return 'Store service error. Please try again later.';
            default:
              return data?['message'] ?? 'Failed to process store request.';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'Network error. Please check your internet connection.';
          }
          return 'Network error. Please check your connection.';
        default:
          return 'Something went wrong with store service.';
      }
    }
    return 'Store service error: ${error.toString()}';
  }

  getAllStores({String? search, String? city}) {}
}
