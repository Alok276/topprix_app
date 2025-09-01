import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';

// Dio Provider - Base HTTP client for API calls with Authentication
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

  // Request interceptor for adding user email to headers and auth management
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Get current user from auth provider
        final authState = ref.read(topPrixAuthProvider);

        // Add user email header if user is authenticated
        if (authState.isAuthenticated && authState.backendUser != null) {
          options.headers['user-email'] = authState.backendUser!.email;

          // Also set the current user email provider for backward compatibility
          ref.read(currentUserEmailProvider.notifier).state =
              authState.backendUser!.email;
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

        // Handle authentication errors
        if (error.response?.statusCode == 401) {
          // Unauthorized - token might be expired or invalid
          print('🔑 Authentication error - user might need to re-login');

          // You could trigger a logout here if needed
          // ref.read(topPrixAuthProvider.notifier).signOut();
        } else if (error.response?.statusCode == 403) {
          // Forbidden - user doesn't have permission for this action
          print('🚫 Permission denied for this action');
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

// Provider for current user email (for backward compatibility)
final currentUserEmailProvider = StateProvider<String?>((ref) {
  // Auto-sync with auth state
  final authState = ref.watch(topPrixAuthProvider);
  return authState.backendUser?.email;
});

// Provider for API base URL (can be changed for different environments)
final apiBaseUrlProvider =
    StateProvider<String>((ref) => 'http://localhost:3000');

// Authenticated Dio Provider - Only provides Dio when user is authenticated
final authenticatedDioProvider = Provider<Dio?>((ref) {
  final authState = ref.watch(topPrixAuthProvider);

  // Only return Dio instance if user is authenticated
  if (authState.isAuthenticated) {
    return ref.read(dioProvider);
  }

  return null;
});

// Helper provider to check if user can make authenticated requests
final canMakeAuthenticatedRequestsProvider = Provider<bool>((ref) {
  final authState = ref.watch(topPrixAuthProvider);
  return authState.isAuthenticated && authState.backendUser != null;
});

// Provider for user role-based API access
final userRoleProvider = Provider<String?>((ref) {
  final authState = ref.watch(topPrixAuthProvider);
  return authState.backendUser?.role;
});

// Provider to check if user is retailer (for retailer-only API calls)
final canAccessRetailerAPIsProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == 'RETAILER' || userRole == 'ADMIN';
});

// Provider to check if user has active subscription (for premium features)
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  final authState = ref.watch(topPrixAuthProvider);
  return authState.backendUser?.hasActiveSubscription ?? false;
});
