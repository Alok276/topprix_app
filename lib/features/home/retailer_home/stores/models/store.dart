// models/store_registration_model.dart
import 'package:topprix/features/home/retailer_home/categories/category_model.dart';

class CreateStoreModel {
  final String name;
  final String logo;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> categoryIds;

  CreateStoreModel({
    required this.name,
    required this.logo,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categoryIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'categoryIds': categoryIds,
    };
  }

  factory CreateStoreModel.fromJson(Map<String, dynamic> json) {
    return CreateStoreModel(
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      categoryIds: List<String>.from(json['categoryIds'] ?? []),
    );
  }
}

class GetStoreModel {
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final List<Store> stores;

  GetStoreModel({
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.stores,
  });

  factory GetStoreModel.fromJson(Map<String, dynamic> json) {
    return GetStoreModel(
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      stores: (json['stores'] as List<dynamic>?)
              ?.map((store) => Store.fromJson(store))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'stores': stores.map((store) => store.toJson()).toList(),
    };
  }
}

class Store {
  final String id;
  final String name;
  final String? logo;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerId;
  final List<StoreCategory> categories;
  final StoreCount count;

  Store({
    required this.id,
    required this.name,
    this.logo,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
    required this.categories,
    required this.count,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      ownerId: json['ownerId'] ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) => StoreCategory.fromJson(category))
              .toList() ??
          [],
      count: StoreCount.fromJson(json['_count'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'ownerId': ownerId,
      'categories': categories.map((category) => category.toJson()).toList(),
      '_count': count.toJson(),
    };
  }
}

class StoreCount {
  final int flyers;
  final int coupons;

  StoreCount({
    required this.flyers,
    required this.coupons,
  });

  factory StoreCount.fromJson(Map<String, dynamic> json) {
    return StoreCount(
      flyers: json['flyers'] ?? 0,
      coupons: json['coupons'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flyers': flyers,
      'coupons': coupons,
    };
  }
}

// Add these functions to your existing CreateStoreService class

// Update Store Response Model
class UpdateStoreResponse {
  final String message;
  final Store store;

  UpdateStoreResponse({
    required this.message,
    required this.store,
  });

  factory UpdateStoreResponse.fromJson(Map<String, dynamic> json) {
    return UpdateStoreResponse(
      message: json['message'] ?? '',
      store: Store.fromJson(json['store']),
    );
  }
}

// Delete Store Response Model
class DeleteStoreResponse {
  final String message;
  final int? flyerCount;
  final int? couponCount;

  DeleteStoreResponse({
    required this.message,
    this.flyerCount,
    this.couponCount,
  });

  factory DeleteStoreResponse.fromJson(Map<String, dynamic> json) {
    return DeleteStoreResponse(
      message: json['message'] ?? '',
      flyerCount: json['details']?['flyerCount'],
      couponCount: json['details']?['couponCount'],
    );
  }
}
