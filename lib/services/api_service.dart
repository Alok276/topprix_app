// lib/services/api_service.dart - Complete Version
import 'package:dio/dio.dart';
import '../models/store_model.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import 'dio_client.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService() : _dioClient = DioClient();

  // ========== USER MANAGEMENT API ==========

  Future<ApiResponse<UserModel>> registerUser({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) async {
    try {
      final response = await _dioClient.dio.post('/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'role': 'USER',
      });

      final user = UserModel.fromJson(response.data['user']);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<UserModel>> getUserProfile(String email) async {
    try {
      final response = await _dioClient.dio.get('/user/$email');
      final user = UserModel.fromJson(response.data);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<UserModel>> updateUserProfile({
    required String email,
    String? username,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (country != null) data['country'] = country;
      if (postalCode != null) data['postalCode'] = postalCode;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await _dioClient.dio.put('/user/$email', data: data);
      final user = UserModel.fromJson(response.data);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> deleteUser(String email) async {
    try {
      await _dioClient.dio.delete('/user/$email');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> updateWishlistItem({
    required String wishlistItemId,
    String? name,
    double? targetPrice,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (targetPrice != null) data['targetPrice'] = targetPrice;

      await _dioClient.dio.put('/api/wishlist/$wishlistItemId', data: data);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== USER PREFERENCES API ==========

  Future<ApiResponse<bool>> addPreferredStore(
      String email, String storeId) async {
    try {
      await _dioClient.dio.post(
        '/user/$email/preferred-stores/add',
        data: {'storeId': storeId},
      );
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> removePreferredStore(
      String email, String storeId) async {
    try {
      await _dioClient.dio.post(
        '/user/$email/preferred-stores/remove',
        data: {'storeId': storeId},
      );
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> addPreferredCategory(
      String email, String categoryId) async {
    try {
      await _dioClient.dio.post(
        '/user/$email/preferred-categories/add',
        data: {'categoryId': categoryId},
      );
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> removePreferredCategory(
      String email, String categoryId) async {
    try {
      await _dioClient.dio.post(
        '/user/$email/preferred-categories/remove',
        data: {'categoryId': categoryId},
      );
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<StoreModel>>> getPreferredStores(String email) async {
    try {
      final response =
          await _dioClient.dio.get('/user/$email/preferred-stores');
      final stores = (response.data['preferredStores'] as List)
          .map((store) => StoreModel.fromJson(store))
          .toList();
      return ApiResponse.success(stores);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<CategoryModel>>> getPreferredCategories(
      String email) async {
    try {
      final response =
          await _dioClient.dio.get('/user/$email/preferred-categories');
      final categories = (response.data['preferredCategories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();
      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== PAYMENT API ==========

  Future<ApiResponse<Map<String, dynamic>>> createPayment({
    required String userId,
    required double amount,
    required String currency,
    required String
        paymentType, // 'SUBSCRIPTION', 'COUPON_PURCHASE', 'FLYER_UPLOAD'
    String? subscriptionId,
    String? couponId,
    String? flyerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dioClient.dio.post('/api/payments', data: {
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'paymentType': paymentType,
        'subscriptionId': subscriptionId,
        'couponId': couponId,
        'flyerId': flyerId,
        'metadata': metadata,
      });

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPaymentById(
      String paymentId) async {
    try {
      final response = await _dioClient.dio.get('/api/payments/$paymentId');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserPayments({
    required String userId,
    String? paymentType,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (paymentType != null) queryParams['paymentType'] = paymentType;
      if (status != null) queryParams['status'] = status;

      final response = await _dioClient.dio.get(
        '/api/payments/user/$userId',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> updatePaymentStatus({
    required String paymentId,
    required String status, // 'PENDING', 'COMPLETED', 'FAILED', 'CANCELLED'
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dioClient.dio.put('/api/payments/$paymentId/status', data: {
        'status': status,
        'transactionId': transactionId,
        'metadata': metadata,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SUBSCRIPTION API ==========

  Future<ApiResponse<Map<String, dynamic>>> createSubscription({
    required String userId,
    required String planId,
    String? paymentMethodId,
  }) async {
    try {
      final response = await _dioClient.dio.post('/api/subscriptions', data: {
        'userId': userId,
        'planId': planId,
        'paymentMethodId': paymentMethodId,
      });

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserSubscription(
      String userId) async {
    try {
      final response =
          await _dioClient.dio.get('/api/subscriptions/user/$userId');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> cancelSubscription(String subscriptionId) async {
    try {
      await _dioClient.dio.post('/api/subscriptions/$subscriptionId/cancel');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> updateSubscription({
    required String subscriptionId,
    String? planId,
    String? paymentMethodId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (planId != null) data['planId'] = planId;
      if (paymentMethodId != null) data['paymentMethodId'] = paymentMethodId;

      await _dioClient.dio
          .put('/api/subscriptions/$subscriptionId', data: data);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== PRICING PLANS API ==========

  Future<ApiResponse<List<Map<String, dynamic>>>> getPricingPlans() async {
    try {
      final response = await _dioClient.dio.get('/api/pricing-plans');
      final plans = List<Map<String, dynamic>>.from(response.data['plans']);
      return ApiResponse.success(plans);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPricingPlanById(
      String planId) async {
    try {
      final response = await _dioClient.dio.get('/api/pricing-plans/$planId');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== NOTIFICATIONS API ==========

  Future<ApiResponse<List<Map<String, dynamic>>>> getUserNotifications({
    required String userId,
    bool? read,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (read != null) queryParams['read'] = read.toString();
      if (type != null) queryParams['type'] = type;

      final response = await _dioClient.dio.get(
        '/api/notifications/user/$userId',
        queryParameters: queryParams,
      );

      final notifications =
          List<Map<String, dynamic>>.from(response.data['notifications']);
      return ApiResponse.success(notifications);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> markNotificationAsRead(
      String notificationId) async {
    try {
      await _dioClient.dio.put('/api/notifications/$notificationId/read');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> markAllNotificationsAsRead(String userId) async {
    try {
      await _dioClient.dio.put('/api/notifications/user/$userId/read-all');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> deleteNotification(String notificationId) async {
    try {
      await _dioClient.dio.delete('/api/notifications/$notificationId');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> updateNotificationSettings({
    required String userId,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? dealAlerts,
    bool? expiryReminders,
    bool? newFlyerAlerts,
    bool? priceDropAlerts,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (emailNotifications != null)
        data['emailNotifications'] = emailNotifications;
      if (pushNotifications != null)
        data['pushNotifications'] = pushNotifications;
      if (dealAlerts != null) data['dealAlerts'] = dealAlerts;
      if (expiryReminders != null) data['expiryReminders'] = expiryReminders;
      if (newFlyerAlerts != null) data['newFlyerAlerts'] = newFlyerAlerts;
      if (priceDropAlerts != null) data['priceDropAlerts'] = priceDropAlerts;

      await _dioClient.dio
          .put('/api/notifications/settings/$userId', data: data);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== ANALYTICS API ==========

  Future<ApiResponse<Map<String, dynamic>>> getUserAnalytics(
      String userId) async {
    try {
      final response = await _dioClient.dio.get('/api/analytics/user/$userId');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> trackUserActivity({
    required String userId,
    required String action, // 'VIEW_FLYER', 'SAVE_COUPON', 'VISIT_STORE', etc.
    String? entityId, // flyerId, couponId, storeId
    String? entityType, // 'flyer', 'coupon', 'store'
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dioClient.dio.post('/api/analytics/track', data: {
        'userId': userId,
        'action': action,
        'entityId': entityId,
        'entityType': entityType,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== SEARCH API ==========

  Future<ApiResponse<Map<String, dynamic>>> searchDeals({
    required String query,
    String? categoryId,
    String? storeId,
    double? minDiscount,
    double? maxDistance,
    double? latitude,
    double? longitude,
    bool showExpiring = false,
    List<String> dealTypes = const ['flyers', 'coupons'],
    String sortBy =
        'relevance', // 'relevance', 'distance', 'discount', 'expiry'
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sortBy': sortBy,
        'limit': limit,
        'page': page,
        'dealTypes': dealTypes.join(','),
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (storeId != null) queryParams['storeId'] = storeId;
      if (minDiscount != null) queryParams['minDiscount'] = minDiscount;
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (showExpiring) queryParams['showExpiring'] = showExpiring;

      final response = await _dioClient.dio.get(
        '/search/deals',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<String>>> getSearchSuggestions(String query) async {
    try {
      final response = await _dioClient.dio.get(
        '/search/suggestions',
        queryParameters: {'q': query},
      );

      final suggestions = List<String>.from(response.data['suggestions']);
      return ApiResponse.success(suggestions);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<String>>> getPopularSearches() async {
    try {
      final response = await _dioClient.dio.get('/search/popular');
      final searches = List<String>.from(response.data['searches']);
      return ApiResponse.success(searches);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== FEEDBACK & REVIEWS API ==========

  Future<ApiResponse<bool>> submitFeedback({
    required String userId,
    required String type, // 'BUG', 'FEATURE_REQUEST', 'GENERAL'
    required String subject,
    required String message,
    String? entityId, // storeId, flyerId, couponId
    String? entityType, // 'store', 'flyer', 'coupon'
    List<String>? attachments,
  }) async {
    try {
      await _dioClient.dio.post('/api/feedback', data: {
        'userId': userId,
        'type': type,
        'subject': subject,
        'message': message,
        'entityId': entityId,
        'entityType': entityType,
        'attachments': attachments,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> rateStore({
    required String userId,
    required String storeId,
    required int rating, // 1-5
    String? review,
  }) async {
    try {
      await _dioClient.dio.post('/api/reviews/store', data: {
        'userId': userId,
        'storeId': storeId,
        'rating': rating,
        'review': review,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getStoreReviews({
    required String storeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/reviews/store/$storeId',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== ADMIN API ==========

  Future<ApiResponse<Map<String, dynamic>>> getAdminDashboard() async {
    try {
      final response = await _dioClient.dio.get('/api/admin/dashboard');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getUsers({
    String? search,
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null) queryParams['search'] = search;
      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final response = await _dioClient.dio.get(
        '/api/admin/users',
        queryParameters: queryParams,
      );

      final users = List<Map<String, dynamic>>.from(response.data['users']);
      return ApiResponse.success(users);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> updateUserRole({
    required String userId,
    required String role, // 'USER', 'RETAILER', 'ADMIN'
  }) async {
    try {
      await _dioClient.dio.put('/api/admin/users/$userId/role', data: {
        'role': role,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> banUser(String userId) async {
    try {
      await _dioClient.dio.post('/api/admin/users/$userId/ban');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> unbanUser(String userId) async {
    try {
      await _dioClient.dio.post('/api/admin/users/$userId/unban');
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== WEBHOOK API ==========

  Future<ApiResponse<bool>> handleWebhook({
    required String provider, // 'stripe', 'paypal', 'firebase'
    required String event,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _dioClient.dio.post('/api/webhooks/$provider', data: {
        'event': event,
        'data': data,
      });
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ========== FILE UPLOAD API ==========

  Future<ApiResponse<Map<String, dynamic>>> uploadFile({
    required String filePath,
    required String fileName,
    String folder = 'general',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'folder': folder,
      });

      final response = await _dioClient.dio.post(
        '/api/upload',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<bool>> deleteFile(String fileUrl) async {
    try {
      await _dioClient.dio.delete('/api/upload', data: {
        'fileUrl': fileUrl,
      });
      return ApiResponse.success(true);
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
              return data?['message'] ??
                  'Bad request. Please check your input.';
            case 401:
              return 'Authentication failed. Please login again.';
            case 403:
              return 'Access denied. You don\'t have permission for this action.';
            case 404:
              return data?['message'] ?? 'Resource not found.';
            case 409:
              return data?['message'] ?? 'Conflict. Resource already exists.';
            case 422:
              return data?['message'] ??
                  'Validation error. Please check your input.';
            case 429:
              return 'Too many requests. Please try again later.';
            case 500:
              return 'Server error. Please try again later.';
            case 503:
              return 'Service unavailable. Please try again later.';
            default:
              return data?['message'] ??
                  'Something went wrong. Please try again.';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'Network error. Please check your internet connection.';
          }
          return 'Network error. Please check your connection.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return error.toString();
  }
}
