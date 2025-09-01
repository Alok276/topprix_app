// Create Flyer Request Model
import 'package:topprix/features/home/retailer_home/categories/category_model.dart';
import 'package:topprix/features/home/retailer_home/stores/models/store.dart';

class CreateFlyerRequest {
  final String title;
  final String storeId;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isSponsored;
  final List<String> categoryIds;

  CreateFlyerRequest({
    required this.title,
    required this.storeId,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.isSponsored = false,
    required this.categoryIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'storeId': storeId,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isSponsored': isSponsored,
      'categoryIds': categoryIds,
    };
  }
}

// Flyer Response Model
class FlyerResponse {
  final String message;
  final Flyer flyer;

  FlyerResponse({
    required this.message,
    required this.flyer,
  });

  factory FlyerResponse.fromJson(Map<String, dynamic> json) {
    return FlyerResponse(
      message: json['message'] ?? '',
      flyer: Flyer.fromJson(json['flyer']),
    );
  }
}

// Flyer Model
class Flyer {
  final String id;
  final String title;
  final String storeId;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSponsored;
  final bool isPremium;
  final Store store;
  final List<StoreCategory> categories;

  Flyer({
    required this.id,
    required this.title,
    required this.storeId,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isSponsored,
    required this.isPremium,
    required this.store,
    required this.categories,
  });

  factory Flyer.fromJson(Map<String, dynamic> json) {
    return Flyer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      storeId: json['storeId'] ?? '',
      imageUrl: json['imageUrl'],
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isSponsored: json['isSponsored'] ?? false,
      isPremium: json['isPremium'] ?? false,
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
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSponsored': isSponsored,
      'isPremium': isPremium,
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
}
