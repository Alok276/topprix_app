import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:topprix/features/home/retailer_home/coupons/model/coupon.dart';
// Import your models
// import 'coupon_models.dart';

class CouponService {
  final Dio _dio = Dio();
  final String baseUrl =
      '${dotenv.env['ENDPOINT']}'; // Replace with your actual base URL

  Future<CouponResponse> createCoupon({
    required String title,
    required String storeId,
    String? code,
    String? barcodeUrl,
    String? qrCodeUrl,
    required String discount,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    bool isOnline = true,
    bool isInStore = true,
    required List<String> categoryIds,
    required String userEmail,
  }) async {
    try {
      final createCouponRequest = CreateCouponRequest(
        title: title,
        storeId: storeId,
        code: code,
        barcodeUrl: barcodeUrl,
        qrCodeUrl: qrCodeUrl,
        discount: discount,
        description: description,
        startDate: startDate,
        endDate: endDate,
        isOnline: isOnline,
        isInStore: isInStore,
        categoryIds: categoryIds,
      );

      print('Creating coupon with data: ${createCouponRequest.toJson()}');

      final response = await _dio.post(
        '${baseUrl}coupons',
        data: createCouponRequest.toJson(),
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Coupon creation response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CouponResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create coupon: ${response.statusMessage}');
      }
    } catch (e) {
      print('Coupon Service Error: $e');
      throw Exception('Failed to create coupon: $e');
    }
  }

  Future<List<Coupon>> getCoupons({
    String? storeId,
    required String userEmail,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (storeId != null) queryParams['storeId'] = storeId;

      final response = await _dio.get(
        '${baseUrl}coupons',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> couponsData;

        if (response.data is List) {
          couponsData = response.data;
        } else if (response.data['coupons'] != null) {
          couponsData = response.data['coupons'];
        } else {
          couponsData = [];
        }

        return couponsData.map((json) => Coupon.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Get Coupons Error: $e');
      throw Exception('Failed to get coupons: $e');
    }
  }

  Future<Coupon> getCouponById({
    required String couponId,
    required String userEmail,
  }) async {
    try {
      final response = await _dio.get(
        '${baseUrl}coupons/$couponId',
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['coupon'] != null) {
          return Coupon.fromJson(response.data['coupon']);
        } else {
          return Coupon.fromJson(response.data);
        }
      } else {
        throw Exception('Coupon not found');
      }
    } catch (e) {
      print('Get Coupon by ID Error: $e');
      throw Exception('Failed to get coupon: $e');
    }
  }

  Future<void> deleteCoupon({
    required String couponId,
    required String userEmail,
  }) async {
    try {
      final response = await _dio.delete(
        '${baseUrl}coupons/$couponId',
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete coupon: ${response.statusMessage}');
      }
    } catch (e) {
      print('Delete Coupon Error: $e');
      throw Exception('Failed to delete coupon: $e');
    }
  }

  Future<Coupon> updateCoupon({
    required String couponId,
    required String title,
    String? code,
    String? barcodeUrl,
    String? qrCodeUrl,
    required String discount,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    bool? isOnline,
    bool? isInStore,
    List<String>? categoryIds,
    required String userEmail,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'title': title,
        'discount': discount,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (code != null) updateData['code'] = code;
      if (barcodeUrl != null) updateData['barcodeUrl'] = barcodeUrl;
      if (qrCodeUrl != null) updateData['qrCodeUrl'] = qrCodeUrl;
      if (description != null) updateData['description'] = description;
      if (isOnline != null) updateData['isOnline'] = isOnline;
      if (isInStore != null) updateData['isInStore'] = isInStore;
      if (categoryIds != null) updateData['categoryIds'] = categoryIds;

      final response = await _dio.put(
        '${baseUrl}coupons/$couponId',
        data: updateData,
        options: Options(
          headers: {
            'user-email': userEmail,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Coupon.fromJson(response.data['coupon'] ?? response.data);
      } else {
        throw Exception('Failed to update coupon: ${response.statusMessage}');
      }
    } catch (e) {
      print('Update Coupon Error: $e');
      throw Exception('Failed to update coupon: $e');
    }
  }
}
