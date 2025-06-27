// lib/services/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;

  // Singleton pattern
  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  DioClient._internal() {
    _initializeDio();
  }

  // Get Dio instance
  Dio get dio => _dio;

  void _initializeDio() {
    _dio = Dio();

    // Base configuration
    _dio.options = BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  // Get base URL based on environment
  String _getBaseUrl() {
    //get url
    return '${dotenv.env['ENDPOINT']}'; // Replace with your production URL
  }

  // Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Update timeout
  void updateTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) _dio.options.connectTimeout = connectTimeout;
    if (receiveTimeout != null) _dio.options.receiveTimeout = receiveTimeout;
    if (sendTimeout != null) _dio.options.sendTimeout = sendTimeout;
  }

  // Clear all interceptors and reinitialize
  void reset() {
    _dio.interceptors.clear();
    _initializeDio();
  }
}

// Auth Interceptor - Adds authentication token to requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Get token from storage
      final token = await StorageService.getToken();

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Add user email for your backend authentication
      final user = await StorageService.getUser();
      if (user != null) {
        options.headers['user-email'] = user.email;
      }

      handler.next(options);
    } catch (e) {
      print('Error in AuthInterceptor: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token expiration
    if (err.response?.statusCode == 401) {
      try {
        // Clear expired token
        await StorageService.removeToken();
        await StorageService.removeUser();

        print('Token expired, redirecting to login');
        // Note: Navigation should be handled by the provider/UI layer
      } catch (e) {
        print('Error handling token expiration: $e');
      }
    }

    handler.next(err);
  }
}

// Logging Interceptor - Logs requests and responses in debug mode
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('Query Parameters: ${options.queryParameters}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
          '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      print('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print(
          '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      print('Message: ${err.message}');
      if (err.response?.data != null) {
        print('Error Data: ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}

// Error Interceptor - Handles common errors and transforms them
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleHttpError(err.response);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'An unexpected error occurred. Please try again.';
        break;
      default:
        errorMessage = 'Something went wrong. Please try again.';
    }

    // Create a new DioException with user-friendly message
    final friendlyError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
      message: errorMessage,
    );

    handler.next(friendlyError);
  }

  String _handleHttpError(Response? response) {
    if (response == null) return 'Server error occurred.';

    switch (response.statusCode) {
      case 400:
        return _extractErrorMessage(response) ??
            'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return _extractErrorMessage(response) ?? 'Conflict occurred.';
      case 422:
        return _extractErrorMessage(response) ?? 'Validation error.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return _extractErrorMessage(response) ?? 'Server error occurred.';
    }
  }

  String? _extractErrorMessage(Response response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? data['detail'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String error,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message, error: $error)';
  }
}

// Helper extension for Dio
extension DioExtensions on Dio {
  // GET request with error handling
  Future<ApiResponse<T>> getApi<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      final data =
          fromJson != null ? fromJson(response.data) : response.data as T;

      return ApiResponse.success(
        data: data,
        message: response.statusMessage,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        error: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: e.toString(),
      );
    }
  }

  // POST request with error handling
  Future<ApiResponse<T>> postApi<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final responseData =
          fromJson != null ? fromJson(response.data) : response.data as T;

      return ApiResponse.success(
        data: responseData,
        message: response.statusMessage,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        error: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: e.toString(),
      );
    }
  }

  // PUT request with error handling
  Future<ApiResponse<T>> putApi<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final responseData =
          fromJson != null ? fromJson(response.data) : response.data as T;

      return ApiResponse.success(
        data: responseData,
        message: response.statusMessage,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        error: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: e.toString(),
      );
    }
  }

  // DELETE request with error handling
  Future<ApiResponse<T>> deleteApi<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final responseData =
          fromJson != null ? fromJson(response.data) : response.data as T;

      return ApiResponse.success(
        data: responseData,
        message: response.statusMessage,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        error: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        error: e.toString(),
      );
    }
  }
}
