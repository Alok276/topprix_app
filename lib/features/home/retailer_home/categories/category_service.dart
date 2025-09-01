// services/category_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:topprix/features/home/retailer_home/categories/category_model.dart';

class CategoryService {
  final Dio _dio = Dio();
  final String baseUrl = '${dotenv.env['ENDPOINT']}categories';

  Future<CategoryResponse?> getAllCategories({
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _dio.get(
        baseUrl,
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return CategoryResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Categories endpoint not found.');
      }
      throw Exception('Failed to fetch categories: ${e.message}');
    }
  }

  Future<StoreCategory?> getCategoryById(String id) async {
    try {
      final response = await _dio.get(
        '$baseUrl/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return StoreCategory.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Category not found.');
      }
      throw Exception('Failed to fetch category: ${e.message}');
    }
  }

  Future<String?> createCategory(
      StoreCategory category, String userEmail) async {
    try {
      final response = await _dio.post(
        baseUrl,
        data: category.toCreateJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'user-email': userEmail,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Category created successfully";
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid category data.');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please check your credentials.');
      }
      throw Exception('Failed to create category: ${e.message}');
    }
  }

  Future<String?> updateCategory(
      String id, StoreCategory category, String userEmail) async {
    try {
      final response = await _dio.put(
        '$baseUrl/$id',
        data: category.toCreateJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'user-email': userEmail,
          },
        ),
      );

      if (response.statusCode == 200) {
        return "Category updated successfully";
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Category not found.');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid category data.');
      }
      throw Exception('Failed to update category: ${e.message}');
    }
  }

  Future<String?> deleteCategory(String id, String userEmail) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'user-email': userEmail,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return "Category deleted successfully";
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Category not found.');
      }
      throw Exception('Failed to delete category: ${e.message}');
    }
  }

  // Get only category names and IDs for dropdown/selection purposes
  Future<List<CategoryOption>> getCategoryOptions() async {
    try {
      final categoryResponse = await getAllCategories();
      if (categoryResponse != null) {
        return categoryResponse.categories
            .map((category) => CategoryOption(
                  id: category.id,
                  name: category.name,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch category options: $e');
    }
  }
}
