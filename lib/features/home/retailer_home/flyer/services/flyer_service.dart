import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:topprix/features/home/retailer_home/flyer/model/flyer_model.dart';
import 'package:topprix/features/home/retailer_home/stores/services/firebase_storage_service.dart';
// Import your models
// import 'flyer_models.dart';

class FlyerService {
  final Dio _dio = Dio();
  final String baseUrl =
      '${dotenv.env['ENDPOINT']}'; // Replace with your actual base URL
  final FirebaseStorageService _storageService = FirebaseStorageService();

  Future<FlyerResponse> createFlyer({
    required String title,
    required String storeId,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    bool isSponsored = false,
    required List<String> categoryIds,
    required String userEmail,
    required String? imagePath,
  }) async {
    try {
      String imageUrl = '';

      // Upload image to Firebase Storage if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        imageUrl = await _storageService.uploadFlyerImage(
          imagePath: imagePath,
        );
      }

      final createFlyerRequest = CreateFlyerRequest(
        title: title,
        storeId: storeId,
        imageUrl: imageUrl,
        startDate: startDate,
        endDate: endDate,
        isSponsored: isSponsored,
        categoryIds: categoryIds,
      );

      print('Creating flyer with data: ${createFlyerRequest.toJson()}');

      final response = await _dio.post(
        '${baseUrl}flyers',
        data: createFlyerRequest.toJson(),
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Flyer creation response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FlyerResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create flyer: ${response.statusMessage}');
      }
    } catch (e) {
      print('Flyer Service Error: $e');
      throw Exception('Failed to create flyer: $e');
    }
  }

  Future<List<Flyer>> getStoreFlyersList({
    required String storeId,
    required String userEmail,
  }) async {
    try {
      final response = await _dio.get(
        '${baseUrl}flyers/',
        queryParameters: {'storeId': storeId},
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> flyersData;

        if (response.data is List) {
          flyersData = response.data;
        } else if (response.data['flyers'] != null) {
          flyersData = response.data['flyers'];
        } else {
          flyersData = [];
        }

        return flyersData.map((json) => Flyer.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Get Store Flyers Error: $e');
      throw Exception('Failed to get store flyers: $e');
    }
  }

  Future<Flyer> updateFlyer({
    required String flyerId,
    required String title,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    bool? isSponsored,
    List<String>? categoryIds,
    required String userEmail,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'title': title,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (isSponsored != null) updateData['isSponsored'] = isSponsored;
      if (categoryIds != null) updateData['categoryIds'] = categoryIds;

      print('Updating flyer with data: $updateData');

      final response = await _dio.put(
        '${baseUrl}flyers/$flyerId',
        data: updateData,
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Flyer update response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // Handle different response structures
        if (response.data['flyer'] != null) {
          return Flyer.fromJson(response.data['flyer']);
        } else {
          return Flyer.fromJson(response.data);
        }
      } else {
        throw Exception('Failed to update flyer: ${response.statusMessage}');
      }
    } catch (e) {
      print('Update Flyer Error: $e');
      throw Exception('Failed to update flyer: $e');
    }
  }

  Future<void> deleteFlyer({
    required String flyerId,
    required String userEmail,
  }) async {
    try {
      print('Deleting flyer with ID: $flyerId');

      final response = await _dio.delete(
        '${baseUrl}flyers/$flyerId',
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Flyer delete response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete flyer: ${response.statusMessage}');
      }
    } catch (e) {
      print('Delete Flyer Error: $e');
      throw Exception('Failed to delete flyer: $e');
    }
  }
}
