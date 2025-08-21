import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Backend User Model (matches your API structure)
class BackendUser {
  final String id;
  final String email;
  final String? phone;
  final String? name;
  final String role; // USER, RETAILER
  final String? location;
  final String? stripeCustomerId;
  final bool hasActiveSubscription;
  final String? subscriptionStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  BackendUser({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    required this.role,
    this.location,
    this.stripeCustomerId,
    this.hasActiveSubscription = false,
    this.subscriptionStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      name: json['name'],
      role: json['role'] ?? 'USER',
      location: json['location'],
      stripeCustomerId: json['stripeCustomerId'],
      hasActiveSubscription: json['hasActiveSubscription'] ?? false,
      subscriptionStatus: json['subscriptionStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'role': role,
      'location': location,
      'stripeCustomerId': stripeCustomerId,
      'hasActiveSubscription': hasActiveSubscription,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// API Response Models
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: json['user'] != null && fromJsonT != null
          ? fromJsonT(json['user'])
          : json['data'],
      error: json['error'],
    );
  }
}

// Custom Dio Interceptor for Logging and Auth
class TopPrixInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 ${options.method} ${options.path}');
    print('📋 Headers: ${options.headers}');
    if (options.data != null) {
      print('📤 Request Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '📡 Response [${response.statusCode}] ${response.requestOptions.path}');
    print('📄 Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ Error [${err.response?.statusCode}] ${err.requestOptions.path}');
    print('💥 Error Message: ${err.message}');
    if (err.response?.data != null) {
      print('📄 Error Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

// Backend User Service with Dio
class BackendUserService {
  static const String baseUrl = 'http://localhost:3000'; // Your backend URL

  late final Dio _dio;

  BackendUserService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(TopPrixInterceptor());

    // Add retry interceptor for network failures
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            // Retry logic can be added here if needed
            print('🔄 Network timeout occurred');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Helper method to add user email header
  Options _getOptions({String? userEmail}) {
    final headers = <String, dynamic>{};
    if (userEmail != null) {
      headers['user-email'] = userEmail;
    }
    return Options(headers: headers);
  }

  // Register user in backend
  Future<ApiResponse<BackendUser>> registerUser({
    required String email,
    required String name,
    required String phone,
    required String role, // USER or RETAILER
    String? location,
  }) async {
    try {
      final data = {
        'username': name, // API expects 'username' but it's the name
        'email': email,
        'phone': phone,
        'location': location,
        'role': role,
      };

      print('🚀 Registering user: $data');

      final response = await _dio.post(
        '/register',
        data: data,
      );

      if (response.statusCode == 201) {
        return ApiResponse<BackendUser>(
          success: true,
          message: response.data['message'] ?? 'User registered successfully',
          data: BackendUser.fromJson(response.data['user']),
        );
      } else {
        return ApiResponse<BackendUser>(
          success: false,
          message: response.data['message'] ?? 'Registration failed',
          error: response.data['error'],
        );
      }
    } on DioException catch (e) {
      return _handleDioError<BackendUser>(e, 'Registration failed');
    } catch (e) {
      print('❌ Registration unexpected error: $e');
      return ApiResponse<BackendUser>(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Get user data from backend
  Future<ApiResponse<BackendUser>> getUser({required String email}) async {
    try {
      print('🔍 Getting user data for: $email');

      final response = await _dio.get(
        '/user/$email',
        options: _getOptions(userEmail: email),
      );

      if (response.statusCode == 200) {
        // Handle different response structures
        Map<String, dynamic> userData;
        if (response.data['user'] != null) {
          userData = response.data['user'];
        } else if (response.data is Map<String, dynamic> &&
            response.data['email'] != null) {
          userData = response.data;
        } else {
          throw Exception('Invalid user data format');
        }

        return ApiResponse<BackendUser>(
          success: true,
          message: 'User data retrieved successfully',
          data: BackendUser.fromJson(userData),
        );
      } else {
        return ApiResponse<BackendUser>(
          success: false,
          message: response.data['message'] ?? 'Failed to get user data',
          error: response.data['error'],
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse<BackendUser>(
          success: false,
          message: 'User not found',
          error: 'user_not_found',
        );
      }
      return _handleDioError<BackendUser>(e, 'Failed to get user data');
    } catch (e) {
      print('❌ Get user unexpected error: $e');
      return ApiResponse<BackendUser>(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Update user data in backend
  Future<ApiResponse<BackendUser>> updateUser({
    required String email,
    String? name,
    String? phone,
    String? location,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (location != null) data['location'] = location;

      print('🔄 Updating user: $data');

      final response = await _dio.post(
        '/user/update/$email',
        data: data,
        options: _getOptions(userEmail: email),
      );

      if (response.statusCode == 200) {
        return ApiResponse<BackendUser>(
          success: true,
          message: response.data['message'] ?? 'User updated successfully',
          data: BackendUser.fromJson(response.data['user']),
        );
      } else {
        return ApiResponse<BackendUser>(
          success: false,
          message: response.data['message'] ?? 'Update failed',
          error: response.data['error'],
        );
      }
    } on DioException catch (e) {
      return _handleDioError<BackendUser>(e, 'Update failed');
    } catch (e) {
      print('❌ Update user unexpected error: $e');
      return ApiResponse<BackendUser>(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Delete user from backend
  Future<ApiResponse<void>> deleteUser({required String email}) async {
    try {
      print('🗑️ Deleting user: $email');

      final response = await _dio.delete(
        '/user/delete/$email',
        options: _getOptions(userEmail: email),
      );

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: 'User deleted successfully',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response.data['message'] ?? 'Delete failed',
          error: response.data['error'],
        );
      }
    } on DioException catch (e) {
      return _handleDioError<void>(e, 'Delete failed');
    } catch (e) {
      print('❌ Delete user unexpected error: $e');
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Check if user exists in backend
  Future<bool> userExists({required String email}) async {
    try {
      final result = await getUser(email: email);
      return result.success && result.data != null;
    } catch (e) {
      print('❌ Check user exists error: $e');
      return false;
    }
  }

  // Sync Firebase user with backend (useful for Google Sign-in)
  Future<ApiResponse<BackendUser>> syncFirebaseUser({
    required String email,
    required String name,
    String? phone,
    String role = 'USER',
  }) async {
    try {
      // First check if user exists
      final existingUser = await getUser(email: email);

      if (existingUser.success && existingUser.data != null) {
        // User exists, return existing data
        return existingUser;
      } else {
        // User doesn't exist, create new one
        return await registerUser(
          email: email,
          name: name,
          phone: phone ?? '',
          role: role,
        );
      }
    } catch (e) {
      print('❌ Sync Firebase user error: $e');
      return ApiResponse<BackendUser>(
        success: false,
        message: 'Failed to sync user data',
        error: e.toString(),
      );
    }
  }

  // Generic Dio error handler
  ApiResponse<T> _handleDioError<T>(DioException error, String defaultMessage) {
    String message = defaultMessage;
    String? errorCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Request timeout. Please check your internet connection.';
        errorCode = 'timeout';
        break;

      case DioExceptionType.badResponse:
        if (error.response?.data != null) {
          final responseData = error.response!.data;
          if (responseData is Map<String, dynamic>) {
            message = responseData['message'] ?? defaultMessage;
            errorCode = responseData['error'];
          }
        }
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        errorCode = 'cancelled';
        break;

      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        errorCode = 'network_error';
        break;

      case DioExceptionType.badCertificate:
        message = 'Certificate verification failed';
        errorCode = 'certificate_error';
        break;

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          message = 'No internet connection';
          errorCode = 'network_error';
        } else {
          message = error.message ?? defaultMessage;
          errorCode = 'unknown';
        }
        break;
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      error: errorCode,
    );
  }

  // Close Dio instance (call this when disposing the service)
  void dispose() {
    _dio.close();
  }
}

// Riverpod Provider
final backendUserServiceProvider = Provider<BackendUserService>((ref) {
  final service = BackendUserService();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// Backend User State Provider
final backendUserProvider = StateProvider<BackendUser?>((ref) => null);

// Service convenience methods provider
final backendUserMethodsProvider = Provider((ref) {
  final service = ref.read(backendUserServiceProvider);
  return service;
});
