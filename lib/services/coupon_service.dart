// lib/services/coupon_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coupon_model.dart';
import '../models/api_response.dart';
import '../models/pagination_meta.dart';
import 'dio_client.dart';

final couponServiceProvider = Provider((ref) => CouponService());

class CouponService {
  final DioClient _dioClient;

  CouponService() : _dioClient = DioClient();

  // ========== GET COUPONS ==========

  /// Get all coupons with filters
  Future<ApiResponse<List<CouponModel>>> getCoupons({
    String? storeId,
    String? categoryId,
    bool? isOnline,
    bool? isInStore,
    bool? active,
    String? search,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };

      if (storeId != null) queryParams['storeId'] = storeId;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isOnline != null) queryParams['isOnline'] = isOnline.toString();
      if (isInStore != null) queryParams['isInStore'] = isInStore.toString();
      if (active != null) queryParams['active'] = active.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dioClient.dio.get(
        '/coupons',
        queryParameters: queryParams,
      );

      final coupons = (response.data['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList();

      final pagination = response.data['pagination'] != null
          ? PaginationMeta.fromJson(response.data['pagination'])
          : null;

      return ApiResponse.success(coupons, pagination: pagination);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get active coupons for homepage
  Future<ApiResponse<List<CouponModel>>> getActiveCoupons({
    String? storeId,
    String? categoryId,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await getCoupons(
        storeId: storeId,
        categoryId: categoryId,
        active: true,
        limit: limit,
        page: page,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get featured coupons (best discounts, popular)
  Future<ApiResponse<List<CouponModel>>> getFeaturedCoupons({
    int limit = 10,
  }) async {
    try {
      final response = await getCoupons(
        active: true,
        limit: limit,
        page: 1,
      );

      if (response.success && response.data != null) {
        // Sort by discount value (highest first)
        final coupons = response.data!;
        coupons.sort((a, b) {
          final aDiscount = _extractDiscountValue(a.discount);
          final bDiscount = _extractDiscountValue(b.discount);
          return bDiscount.compareTo(aDiscount);
        });

        return ApiResponse.success(coupons.take(limit).toList());
      }

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get online coupons only
  Future<ApiResponse<List<CouponModel>>> getOnlineCoupons({
    String? storeId,
    String? categoryId,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await getCoupons(
        storeId: storeId,
        categoryId: categoryId,
        isOnline: true,
        active: true,
        limit: limit,
        page: page,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get in-store coupons only
  Future<ApiResponse<List<CouponModel>>> getInStoreCoupons({
    String? storeId,
    String? categoryId,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await getCoupons(
        storeId: storeId,
        categoryId: categoryId,
        isInStore: true,
        active: true,
        limit: limit,
        page: page,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get coupons by store
  Future<ApiResponse<List<CouponModel>>> getCouponsByStore(
    String storeId, {
    bool activeOnly = true,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await getCoupons(
        storeId: storeId,
        active: activeOnly,
        limit: limit,
        page: page,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get coupons by category
  Future<ApiResponse<List<CouponModel>>> getCouponsByCategory(
    String categoryId, {
    bool activeOnly = true,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await getCoupons(
        categoryId: categoryId,
        active: activeOnly,
        limit: limit,
        page: page,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get expiring coupons
  Future<ApiResponse<List<CouponModel>>> getExpiringCoupons({
    int hoursRemaining = 24,
    int limit = 20,
  }) async {
    try {
      final response = await getCoupons(
        active: true,
        limit: 100, // Get more to filter
      );

      if (response.success && response.data != null) {
        final expiringCoupons = response.data!.where((coupon) {
          final timeRemaining = coupon.endDate.difference(DateTime.now());
          return timeRemaining.inHours <= hoursRemaining &&
              timeRemaining.inHours > 0;
        }).toList();

        // Sort by expiration time (soonest first)
        expiringCoupons.sort((a, b) => a.endDate.compareTo(b.endDate));

        return ApiResponse.success(expiringCoupons.take(limit).toList());
      }

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SINGLE COUPON OPERATIONS ==========

  /// Get coupon by ID
  Future<ApiResponse<CouponModel>> getCouponById(String couponId) async {
    try {
      final response = await _dioClient.dio.get('/coupons/$couponId');
      final coupon = CouponModel.fromJson(response.data);
      return ApiResponse.success(coupon);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get coupon detail with analytics tracking
  Future<ApiResponse<CouponModel>> getCouponDetail(
    String couponId, {
    String? userId,
  }) async {
    try {
      final response = await _dioClient.dio.get('/coupons/$couponId');
      final coupon = CouponModel.fromJson(response.data);

      // Track view analytics if userId provided
      if (userId != null) {
        _trackCouponView(couponId, userId);
      }

      return ApiResponse.success(coupon);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SAVE/UNSAVE COUPONS ==========

  /// Save/clip a coupon for the user
  Future<ApiResponse<bool>> saveCoupon(String couponId) async {
    try {
      await _dioClient.dio.post('/coupons/save', data: {
        'couponId': couponId,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Remove saved coupon
  Future<ApiResponse<bool>> unsaveCoupon(String couponId) async {
    try {
      await _dioClient.dio.post('/coupons/unsave', data: {
        'couponId': couponId,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get user's saved coupons
  Future<ApiResponse<List<CouponModel>>> getUserSavedCoupons(
      String userId) async {
    try {
      final response = await _dioClient.dio.get('/users/$userId/coupons');
      final coupons = (response.data['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList();
      return ApiResponse.success(coupons);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Check if coupon is saved by user
  Future<ApiResponse<bool>> isCouponSaved(
      String couponId, String userId) async {
    try {
      final response = await _dioClient.dio
          .get('/coupons/$couponId/saved', queryParameters: {'userId': userId});
      final isSaved = response.data['isSaved'] as bool;
      return ApiResponse.success(isSaved);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get saved coupons by category
  Future<ApiResponse<List<CouponModel>>> getSavedCouponsByCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      final response = await _dioClient.dio.get('/users/$userId/coupons',
          queryParameters: {'categoryId': categoryId});
      final coupons = (response.data['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList();
      return ApiResponse.success(coupons);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== CREATE/UPDATE COUPONS (Admin/Retailer) ==========

  /// Create a new coupon
  Future<ApiResponse<CouponModel>> createCoupon({
    required String title,
    required String storeId,
    String? code,
    String? barcodeUrl,
    String? qrCodeUrl,
    required String discount,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    bool isOnline = true,
    bool isInStore = true,
    List<String>? categoryIds,
  }) async {
    try {
      final response = await _dioClient.dio.post('/coupons', data: {
        'title': title,
        'storeId': storeId,
        'code': code,
        'barcodeUrl': barcodeUrl,
        'qrCodeUrl': qrCodeUrl,
        'discount': discount,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isOnline': isOnline,
        'isInStore': isInStore,
        'categoryIds': categoryIds,
      });

      final coupon = CouponModel.fromJson(response.data);
      return ApiResponse.success(coupon);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Update existing coupon
  Future<ApiResponse<CouponModel>> updateCoupon({
    required String couponId,
    String? title,
    String? code,
    String? barcodeUrl,
    String? qrCodeUrl,
    String? discount,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isOnline,
    bool? isInStore,
    List<String>? categoryIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (code != null) data['code'] = code;
      if (barcodeUrl != null) data['barcodeUrl'] = barcodeUrl;
      if (qrCodeUrl != null) data['qrCodeUrl'] = qrCodeUrl;
      if (discount != null) data['discount'] = discount;
      if (description != null) data['description'] = description;
      if (startDate != null) data['startDate'] = startDate.toIso8601String();
      if (endDate != null) data['endDate'] = endDate.toIso8601String();
      if (isOnline != null) data['isOnline'] = isOnline;
      if (isInStore != null) data['isInStore'] = isInStore;
      if (categoryIds != null) data['categoryIds'] = categoryIds;

      final response =
          await _dioClient.dio.put('/coupons/$couponId', data: data);
      final coupon = CouponModel.fromJson(response.data);
      return ApiResponse.success(coupon);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Delete a coupon
  Future<ApiResponse<bool>> deleteCoupon(String couponId) async {
    try {
      await _dioClient.dio.delete('/coupons/$couponId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH COUPONS ==========

  /// Search coupons with query
  Future<ApiResponse<List<CouponModel>>> searchCoupons(
    String query, {
    String? storeId,
    String? categoryId,
    bool? isOnline,
    bool? isInStore,
    bool activeOnly = true,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await getCoupons(
        search: query,
        storeId: storeId,
        categoryId: categoryId,
        isOnline: isOnline,
        isInStore: isInStore,
        active: activeOnly,
        limit: limit,
        page: page,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Search coupons by discount amount
  Future<ApiResponse<List<CouponModel>>> searchCouponsByDiscount({
    double? minDiscount,
    double? maxDiscount,
    String? storeId,
    String? categoryId,
    int limit = 20,
  }) async {
    try {
      final response = await getCoupons(
        storeId: storeId,
        categoryId: categoryId,
        active: true,
        limit: 100, // Get more to filter
      );

      if (response.success && response.data != null) {
        var filteredCoupons = response.data!;

        if (minDiscount != null || maxDiscount != null) {
          filteredCoupons = filteredCoupons.where((coupon) {
            final discountValue = _extractDiscountValue(coupon.discount);

            if (minDiscount != null && discountValue < minDiscount) {
              return false;
            }
            if (maxDiscount != null && discountValue > maxDiscount) {
              return false;
            }
            return true;
          }).toList();
        }

        // Sort by discount value (highest first)
        filteredCoupons.sort((a, b) {
          final aDiscount = _extractDiscountValue(a.discount);
          final bDiscount = _extractDiscountValue(b.discount);
          return bDiscount.compareTo(aDiscount);
        });

        return ApiResponse.success(filteredCoupons.take(limit).toList());
      }

      return response;
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== COUPON USAGE ==========

  /// Mark coupon as used
  Future<ApiResponse<bool>> useCoupon({
    required String couponId,
    required String userId,
    double? orderAmount,
    String? orderId,
  }) async {
    try {
      await _dioClient.dio.post('/coupons/$couponId/use', data: {
        'userId': userId,
        'orderAmount': orderAmount,
        'orderId': orderId,
        'usedAt': DateTime.now().toIso8601String(),
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get coupon usage history
  Future<ApiResponse<List<Map<String, dynamic>>>> getCouponUsageHistory({
    required String couponId,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.dio.get('/coupons/$couponId/usage',
          queryParameters: {'limit': limit, 'page': page});

      final usage = List<Map<String, dynamic>>.from(response.data['usage']);
      return ApiResponse.success(usage);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get user's coupon usage history
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserCouponUsage({
    required String userId,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.dio.get('/users/$userId/coupon-usage',
          queryParameters: {'limit': limit, 'page': page});

      final usage = List<Map<String, dynamic>>.from(response.data['usage']);
      return ApiResponse.success(usage);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== COUPON VALIDATION ==========

  /// Validate coupon code
  Future<ApiResponse<Map<String, dynamic>>> validateCouponCode({
    required String code,
    String? storeId,
    double? orderAmount,
  }) async {
    try {
      final response = await _dioClient.dio.post('/coupons/validate', data: {
        'code': code,
        'storeId': storeId,
        'orderAmount': orderAmount,
      });

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Check coupon eligibility for user
  Future<ApiResponse<bool>> checkCouponEligibility({
    required String couponId,
    required String userId,
    double? orderAmount,
  }) async {
    try {
      final response = await _dioClient.dio
          .post('/coupons/$couponId/check-eligibility', data: {
        'userId': userId,
        'orderAmount': orderAmount,
      });

      final isEligible = response.data['eligible'] as bool;
      return ApiResponse.success(isEligible);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== COUPON STATISTICS ==========

  /// Get coupon statistics (saves, uses, views)
  Future<ApiResponse<Map<String, dynamic>>> getCouponStats(
      String couponId) async {
    try {
      final response = await _dioClient.dio.get('/coupons/$couponId/stats');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get store's coupon performance
  Future<ApiResponse<Map<String, dynamic>>> getStoreCouponPerformance(
      String storeId) async {
    try {
      final response =
          await _dioClient.dio.get('/stores/$storeId/coupons/stats');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== COUPON SHARING ==========

  /// Generate shareable link for coupon
  Future<ApiResponse<String>> generateCouponShareLink(String couponId) async {
    try {
      final response = await _dioClient.dio.post('/coupons/$couponId/share');
      final shareLink = response.data['shareLink'] as String;
      return ApiResponse.success(shareLink);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Track coupon share
  Future<ApiResponse<bool>> trackCouponShare({
    required String couponId,
    required String platform, // 'facebook', 'twitter', 'whatsapp', 'email'
    String? userId,
  }) async {
    try {
      await _dioClient.dio.post('/coupons/$couponId/track-share', data: {
        'platform': platform,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== COUPON RECOMMENDATIONS ==========

  /// Get personalized coupon recommendations
  Future<ApiResponse<List<CouponModel>>> getRecommendedCoupons({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
          '/coupons/recommendations/$userId',
          queryParameters: {'limit': limit});

      final coupons = (response.data['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList();

      return ApiResponse.success(coupons);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Get similar coupons
  Future<ApiResponse<List<CouponModel>>> getSimilarCoupons({
    required String couponId,
    int limit = 5,
  }) async {
    try {
      final response = await _dioClient.dio
          .get('/coupons/$couponId/similar', queryParameters: {'limit': limit});

      final coupons = (response.data['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList();

      return ApiResponse.success(coupons);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== BULK OPERATIONS ==========

  /// Bulk save coupons
  Future<ApiResponse<bool>> bulkSaveCoupons(List<String> couponIds) async {
    try {
      await _dioClient.dio.post('/coupons/bulk-save', data: {
        'couponIds': couponIds,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Bulk delete coupons
  Future<ApiResponse<bool>> bulkDeleteCoupons(List<String> couponIds) async {
    try {
      await _dioClient.dio.post('/coupons/bulk-delete', data: {
        'couponIds': couponIds,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Bulk update coupon status
  Future<ApiResponse<bool>> bulkUpdateCouponStatus({
    required List<String> couponIds,
    required bool isActive,
  }) async {
    try {
      await _dioClient.dio.post('/coupons/bulk-update-status', data: {
        'couponIds': couponIds,
        'isActive': isActive,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== QR CODE & BARCODE ==========

  /// Generate QR code for coupon
  Future<ApiResponse<String>> generateCouponQRCode(String couponId) async {
    try {
      final response =
          await _dioClient.dio.post('/coupons/$couponId/generate-qr');
      final qrCodeUrl = response.data['qrCodeUrl'] as String;
      return ApiResponse.success(qrCodeUrl);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// Generate barcode for coupon
  Future<ApiResponse<String>> generateCouponBarcode(String couponId) async {
    try {
      final response =
          await _dioClient.dio.post('/coupons/$couponId/generate-barcode');
      final barcodeUrl = response.data['barcodeUrl'] as String;
      return ApiResponse.success(barcodeUrl);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== UTILITY METHODS ==========

  /// Extract numeric discount value from discount string
  double _extractDiscountValue(String discount) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(discount);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    return 0.0;
  }

  /// Track coupon view for analytics
  Future<void> _trackCouponView(String couponId, String userId) async {
    try {
      await _dioClient.dio.post('/analytics/track', data: {
        'userId': userId,
        'action': 'VIEW_COUPON',
        'entityId': couponId,
        'entityType': 'coupon',
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
                  'Invalid coupon data. Please check your input.';
            case 401:
              return 'Authentication failed. Please login again.';
            case 403:
              return 'Access denied. You don\'t have permission to access this coupon.';
            case 404:
              return data?['message'] ?? 'Coupon not found.';
            case 409:
              return data?['message'] ??
                  'Coupon already exists or has been used.';
            case 410:
              return 'This coupon has expired.';
            case 422:
              return data?['message'] ??
                  'Invalid coupon data. Please check your input.';
            case 429:
              return 'Too many requests. Please try again later.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return data?['message'] ?? 'Failed to process coupon request.';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'Network error. Please check your internet connection.';
          }
          return 'Network error. Please check your connection.';
        default:
          return 'Something went wrong with coupon service.';
      }
    }
    return 'Coupon service error: ${error.toString()}';
  }
}
