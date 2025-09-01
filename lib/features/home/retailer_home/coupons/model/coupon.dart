// Create Coupon Request Model
import 'package:topprix/features/home/retailer_home/categories/category_model.dart';
import 'package:topprix/features/home/retailer_home/stores/models/store.dart';

class CreateCouponRequest {
  final String title;
  final String storeId;
  final String? code;
  final String? barcodeUrl;
  final String? qrCodeUrl;
  final String discount;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isOnline;
  final bool isInStore;
  final List<String> categoryIds;

  CreateCouponRequest({
    required this.title,
    required this.storeId,
    this.code,
    this.barcodeUrl,
    this.qrCodeUrl,
    required this.discount,
    this.description,
    required this.startDate,
    required this.endDate,
    this.isOnline = true,
    this.isInStore = true,
    required this.categoryIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'storeId': storeId,
      'code': code,
      'barcodeUrl': barcodeUrl,
      'qrCodeUrl': qrCodeUrl,
      'discount': discount,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isOnline': isOnline,
      'isInStore': isInStore,
      'categoryIds': categoryIds,
    };
  }
}

// Coupon Response Model
class CouponResponse {
  final String message;
  final Coupon coupon;

  CouponResponse({
    required this.message,
    required this.coupon,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      message: json['message'] ?? '',
      coupon: Coupon.fromJson(json['coupon']),
    );
  }
}

// Coupon Model
class Coupon {
  final String id;
  final String title;
  final String storeId;
  final String? code;
  final String? barcodeUrl;
  final String? qrCodeUrl;
  final String discount;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isOnline;
  final bool isInStore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Store store;
  final List<StoreCategory> categories;

  Coupon({
    required this.id,
    required this.title,
    required this.storeId,
    this.code,
    this.barcodeUrl,
    this.qrCodeUrl,
    required this.discount,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.isOnline,
    required this.isInStore,
    required this.createdAt,
    required this.updatedAt,
    required this.store,
    required this.categories,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      storeId: json['storeId'] ?? '',
      code: json['code'],
      barcodeUrl: json['barcodeUrl'],
      qrCodeUrl: json['qrCodeUrl'],
      discount: json['discount'] ?? '',
      description: json['description'],
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isOnline: json['isOnline'] ?? true,
      isInStore: json['isInStore'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      store: Store.fromJson(json['store']),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) => StoreCategory.fromJson(category))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'storeId': storeId,
      'code': code,
      'barcodeUrl': barcodeUrl,
      'qrCodeUrl': qrCodeUrl,
      'discount': discount,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isOnline': isOnline,
      'isInStore': isInStore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'store': store.toJson(),
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }

  // Helper methods
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    return endDate.difference(now);
  }

  bool get isExpiring {
    return timeRemaining.inHours <= 24 && timeRemaining.inHours > 0;
  }

  String get availabilityText {
    if (isOnline && isInStore) return 'Online & In-Store';
    if (isOnline) return 'Online Only';
    if (isInStore) return 'In-Store Only';
    return 'Not Available';
  }
}
