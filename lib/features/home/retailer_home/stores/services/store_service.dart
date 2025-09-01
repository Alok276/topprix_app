// services/store_registration_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/home/retailer_home/categories/category_model.dart';
import 'package:topprix/features/home/retailer_home/categories/category_service.dart';
import 'package:topprix/features/home/retailer_home/stores/models/store.dart';

import 'firebase_storage_service.dart';

class CreateStoreService {
  final Dio _dio = Dio();
  final String baseUrl = '${dotenv.env['ENDPOINT']}';
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final CategoryService _categoryService = CategoryService();
  final TopPrixAuthService _authService = TopPrixAuthService();

  Future<String?> registerStore(
    CreateStoreModel model,
    String? logoPath,
  ) async {
    try {
      String logoUrl = '';

      // Upload logo to Firebase Storage if provided
      if (logoPath != null && logoPath.isNotEmpty) {
        logoUrl = await _storageService.uploadStoreLogo(
          logoPath: logoPath,
        );
      }

      String userEmail = await _authService.getCurrentUserEmail();
      if (userEmail.isEmpty) {
        throw Exception('User email not found. Please log in again.');
      }
      // Create the updated model with uploaded logo URL
      final updatedModel = CreateStoreModel(
        name: model.name,
        logo: logoUrl.isNotEmpty ? logoUrl : model.logo,
        description: model.description,
        address: model.address,
        latitude: model.latitude,
        longitude: model.longitude,
        categoryIds: model.categoryIds,
      );

      final response = await _dio.post(
        '${baseUrl}store',
        data: updatedModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'user-email': userEmail,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Store registration successful";
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            'API endpoint not found. Please verify the URL and parameters.');
      }
      if (e.response?.statusCode == 400) {
        throw Exception(
            'Invalid request data. Please check all required fields.');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please check your credentials.');
      }
      throw Exception('Failed to register store: ${e.message}');
    }
  }

  Future<List<CategoryOption>> getStoreCategories() async {
    try {
      return await _categoryService.getCategoryOptions();
    } catch (e) {
      // Return default categories if API fails
      return [];
    }
  }

  Future<CategoryResponse?> getFullCategoryData({
    int? page,
    int? limit,
  }) async {
    try {
      return await _categoryService.getAllCategories(page: page, limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch category data: $e');
    }
  }

  Future<GetStoreModel> getUserStores(String userEmail) async {
    try {
      final response = await _dio.get(
        '${baseUrl}stores',
        options: Options(
          headers: {
            'user-email': userEmail,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse the entire response using GetStoreModel
        final storeResponse = GetStoreModel.fromJson(response.data);
        return storeResponse;
      }

      // Return empty response if no data
      return GetStoreModel(
        totalCount: 0,
        currentPage: 1,
        totalPages: 1,
        stores: [],
      );
    } catch (e) {
      print('API Error: $e');
      throw Exception('Failed to fetch user stores: $e');
    }
  }

  Future<UpdateStoreResponse> updateStore({
    required String storeId,
    required String name,
    String? description,
    String? address,
    List<String>? categoryIds,
    required String userEmail,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': name,
      };

      if (description != null) updateData['description'] = description;
      if (address != null) updateData['address'] = address;
      if (categoryIds != null) updateData['categoryIds'] = categoryIds;

      print('Updating store with data: $updateData');

      final response = await _dio.put(
        '${baseUrl}store/$storeId',
        data: updateData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'user-email': userEmail,
          },
        ),
      );

      print('Store update response: ${response.data}');

      if (response.statusCode == 200) {
        return UpdateStoreResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update store: ${response.statusMessage}');
      }
    } catch (e) {
      print('Update Store Service Error: $e');
      throw Exception('Failed to update store: $e');
    }
  }

// Delete Store Function
  Future<DeleteStoreResponse> deleteStore({
    required String storeId,
    required String userEmail,
  }) async {
    try {
      print('Deleting store with ID: $storeId');

      final response = await _dio.delete(
        '${baseUrl}store/$storeId',
        options: Options(
          headers: {
            'user-email': userEmail,
          },
        ),
      );

      print('Store delete response: ${response.data}');

      if (response.statusCode == 200) {
        return DeleteStoreResponse.fromJson(response.data);
      } else if (response.statusCode == 409) {
        // Conflict - store has related items
        return DeleteStoreResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to delete store: ${response.statusMessage}');
      }
    } catch (e) {
      print('Delete Store Service Error: $e');

      // Handle DioException for conflict responses
      if (e is DioException && e.response?.statusCode == 409) {
        return DeleteStoreResponse.fromJson(e.response!.data);
      }

      throw Exception('Failed to delete store: $e');
    }
  }
}
