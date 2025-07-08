import 'package:topprix/models/category_model.dart';
import 'package:topprix/models/store_model.dart';

class CouponModel {
  final String id;
  final String title;
  final String storeId;
  final StoreModel store;
  final String? code;
  final String? barcodeUrl;
  final String? qrCodeUrl;
  final String discount;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isOnline;
  final bool isInStore;
  final List<CategoryModel> categories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSaved;

  CouponModel({
    required this.id,
    required this.title,
    required this.storeId,
    required this.store,
    this.code,
    this.barcodeUrl,
    this.qrCodeUrl,
    required this.discount,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.isOnline,
    required this.isInStore,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
    this.isSaved = false,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      title: json['title'],
      storeId: json['storeId'],
      store: StoreModel.fromJson(json['store']),
      code: json['code'],
      barcodeUrl: json['barcodeUrl'],
      qrCodeUrl: json['qrCodeUrl'],
      discount: json['discount'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isOnline: json['isOnline'] ?? true,
      isInStore: json['isInStore'] ?? true,
      categories: (json['categories'] as List?)
              ?.map((category) => CategoryModel.fromJson(category))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSaved: json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'storeId': storeId,
      'store': store.toJson(),
      'code': code,
      'barcodeUrl': barcodeUrl,
      'qrCodeUrl': qrCodeUrl,
      'discount': discount,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isOnline': isOnline,
      'isInStore': isInStore,
      'categories': categories.map((category) => category.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSaved': isSaved,
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

  CouponModel copyWith({bool? isSaved}) {
    return CouponModel(
      id: id,
      title: title,
      storeId: storeId,
      store: store,
      code: code,
      barcodeUrl: barcodeUrl,
      qrCodeUrl: qrCodeUrl,
      discount: discount,
      description: description,
      startDate: startDate,
      endDate: endDate,
      isOnline: isOnline,
      isInStore: isInStore,
      categories: categories,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
