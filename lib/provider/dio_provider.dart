import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dio Provider - Base HTTP client for API calls
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Base configuration
  dio.options = BaseOptions(
    baseUrl: 'http://localhost:3000', // Your API base URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  // Request interceptor for adding user email to headers
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add user email header if available
        // This will be set from auth service when user is logged in
        final userEmail = ref.read(currentUserEmailProvider);
        if (userEmail != null) {
          options.headers['user-email'] = userEmail;
        }

        // Debug logging
        print('🚀 REQUEST: ${options.method} ${options.uri}');
        if (options.data != null) {
          print('📤 DATA: ${options.data}');
        }
        if (options.headers.isNotEmpty) {
          print('📋 HEADERS: ${options.headers}');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        print(
            '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
        print('❌ MESSAGE: ${error.message}');

        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Unauthorized - redirect to login
          // You can add logout logic here
        } else if (error.response?.statusCode == 403) {
          // Forbidden - user doesn't have permission
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

// Provider for current user email (from auth service)
final currentUserEmailProvider = StateProvider<String?>((ref) => null);

// Provider for API base URL (can be changed for different environments)
final apiBaseUrlProvider =
    StateProvider<String>((ref) => 'http://localhost:3000');
