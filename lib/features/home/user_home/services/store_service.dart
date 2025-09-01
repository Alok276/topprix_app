import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/home/user_home/services/categories_service.dart';
import 'package:topprix/core/provider/dio_provider.dart';
import 'package:topprix/features/auth/service/backend_user_service.dart';

// Store Model
class Store {
  final String id;
  final String name;
  final String? logo;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? ownerId;
  final List<Category> categories;
  final BackendUser? owner;
  final int flyersCount;
  final int couponsCount;
  final bool isPreferred;
  final double? distance; // in km
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.ownerId,
    this.categories = const [],
    this.owner,
    this.flyersCount = 0,
    this.couponsCount = 0,
    this.isPreferred = false,
    this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      ownerId: json['ownerId'],
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((e) => Category.fromJson(e))
              .toList()
          : [],
      owner: json['owner'] != null ? BackendUser.fromJson(json['owner']) : null,
      flyersCount: json['flyersCount'] ?? 0,
      couponsCount: json['couponsCount'] ?? 0,
      isPreferred: json['isPreferred'] ?? false,
      distance: json['distance']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Stores Service
class StoresService {
  final Dio _dio;

  StoresService(this._dio);

  Future<List<Store>> getStores({
    String? categoryId,
    String? name,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category'] = categoryId;
      if (name != null) queryParams['name'] = name;
      if (location != null) queryParams['location'] = location;

      final response = await _dio.get('/stores', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> storesJson = response.data is List
            ? response.data
            : response.data['stores'] ?? [];
        return storesJson.map((json) => Store.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching stores: $e');
      return [];
    }
  }

  Future<Store?> getStoreById(String id) async {
    try {
      final response = await _dio.get('/store/$id');

      if (response.statusCode == 200) {
        return Store.fromJson(response.data['store'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching store: $e');
      return null;
    }
  }

  Future<List<Store>> getNearbyStores({
    required double latitude,
    required double longitude,
    int radius = 10, // km
  }) async {
    try {
      final response = await _dio.get(
        '/location/nearby-stores',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesJson = response.data is List
            ? response.data
            : response.data['stores'] ?? [];
        return storesJson.map((json) => Store.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching nearby stores: $e');
      return [];
    }
  }

  Future<bool> addPreferredStore(String storeId, String userEmail) async {
    try {
      final response = await _dio.post(
        '/user/$userEmail/preferred-stores/add',
        data: {'storeId': storeId},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding preferred store: $e');
      return false;
    }
  }

  Future<bool> removePreferredStore(String storeId, String userEmail) async {
    try {
      final response = await _dio.post(
        '/user/$userEmail/preferred-stores/remove',
        data: {'storeId': storeId},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing preferred store: $e');
      return false;
    }
  }

  Future<List<Store>> getPreferredStores(String userEmail) async {
    try {
      final response = await _dio.get(
        '/user/$userEmail/preferred-stores',
        options: Options(headers: {'user-email': userEmail}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesJson = response.data is List
            ? response.data
            : response.data['stores'] ?? [];
        return storesJson.map((json) => Store.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching preferred stores: $e');
      return [];
    }
  }

  Future<bool> createStore({
    required String name,
    String? description,
    String? logo,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? categoryIds,
    required String userEmail,
  }) async {
    try {
      final response = await _dio.post(
        '/store',
        data: {
          'name': name,
          'description': description,
          'logo': logo,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'categoryIds': categoryIds,
        },
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating store: $e');
      return false;
    }
  }
}

// Providers
final storesServiceProvider = Provider<StoresService>((ref) {
  final dio = ref.read(dioProvider);
  return StoresService(dio);
});

final storesProvider = FutureProvider<List<Store>>((ref) async {
  final service = ref.read(storesServiceProvider);
  return service.getStores();
});

final nearbyStoresProvider =
    FutureProvider.family<List<Store>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.read(storesServiceProvider);
  return service.getNearbyStores(
    latitude: params['latitude'] as double,
    longitude: params['longitude'] as double,
    radius: params['radius'] as int? ?? 10,
  );
});

final preferredStoresProvider = FutureProvider<List<Store>>((ref) async {
  final service = ref.read(storesServiceProvider);
  final user = ref.read(currentBackendUserProvider);

  if (user != null) {
    return service.getPreferredStores(user.email);
  }
  return [];
});
