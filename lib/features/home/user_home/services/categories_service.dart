import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/provider/dio_provider.dart';

// Category Model
class Category {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Categories Service
class CategoriesService {
  final Dio _dio;

  CategoriesService(this._dio);

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = response.data is List
            ? response.data
            : response.data['categories'] ?? [];

        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _dio.get('/category/$id');

      if (response.statusCode == 200) {
        return Category.fromJson(response.data['category'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }

  Future<bool> createCategory({
    required String name,
    String? description,
    required String userEmail,
  }) async {
    try {
      final response = await _dio.post(
        '/category',
        data: {
          'name': name,
          'description': description,
        },
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }
}

// Provider
final categoriesServiceProvider = Provider<CategoriesService>((ref) {
  final dio = ref.read(dioProvider);
  return CategoriesService(dio);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.read(categoriesServiceProvider);
  return service.getAllCategories();
});
