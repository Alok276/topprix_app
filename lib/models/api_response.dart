import 'package:topprix/models/pagination_meta.dart';

class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final String? error;
  final PaginationMeta? pagination;

  ApiResponse({
    this.data,
    required this.success,
    this.message,
    this.error,
    this.pagination,
  });

  factory ApiResponse.success(T data, {PaginationMeta? pagination}) {
    return ApiResponse(
      data: data,
      success: true,
      pagination: pagination,
    );
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(
      success: false,
      error: error,
    );
  }
}
