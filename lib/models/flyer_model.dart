import 'package:topprix/models/category_model.dart';
import 'package:topprix/models/flyer_item_model.dart';
import 'package:topprix/models/store_model.dart';

class FlyerModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isSponsored;
  final String storeId;
  final StoreModel store;
  final List<CategoryModel> categories;
  final List<FlyerItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlyerModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.isSponsored,
    required this.storeId,
    required this.store,
    required this.categories,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlyerModel.fromJson(Map<String, dynamic> json) {
    return FlyerModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isSponsored: json['isSponsored'] ?? false,
      storeId: json['storeId'],
      store: StoreModel.fromJson(json['store']),
      categories: (json['categories'] as List?)
              ?.map((category) => CategoryModel.fromJson(category))
              .toList() ??
          [],
      items: (json['items'] as List?)
              ?.map((item) => FlyerItemModel.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isSponsored': isSponsored,
      'storeId': storeId,
      'store': store.toJson(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
}
