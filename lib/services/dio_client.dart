// lib/services/dio_client.dart - Updated
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

final dioClientProvider = Provider((ref) => DioClient());

class DioClient {
  final baseUrl = '${dotenv.env['ENDPOINT']}';
  // Update this URL
  late Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add user email from Firebase if available
          final userEmail = await StorageService.getUserEmail();
          if (userEmail != null && userEmail.isNotEmpty) {
            options.headers['X-User-Email'] = userEmail;
          }

          print('🚀 ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ${error.response?.statusCode} ${error.requestOptions.path}');
          print('Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }
}
