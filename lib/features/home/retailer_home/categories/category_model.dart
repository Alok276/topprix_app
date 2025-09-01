// Model for the complete API response
class CategoryResponse {
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final List<StoreCategory> categories;

  CategoryResponse({
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.categories,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((categoryJson) => StoreCategory.fromJson(categoryJson))
          .toList(),
    );
  }
}

// Main category model with all fields
class StoreCategory {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryCount count;

  StoreCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.count,
  });

  factory StoreCategory.fromJson(Map<String, dynamic> json) {
    return StoreCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      count: CategoryCount.fromJson(json['_count'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '_count': count.toJson(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

// Category count model
class CategoryCount {
  final int stores;
  final int flyers;
  final int coupons;

  CategoryCount({
    required this.stores,
    required this.flyers,
    required this.coupons,
  });

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      stores: json['stores'] ?? 0,
      flyers: json['flyers'] ?? 0,
      coupons: json['coupons'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stores': stores,
      'flyers': flyers,
      'coupons': coupons,
    };
  }
}

// Simplified model for dropdowns and selections (only ID and name)
class CategoryOption {
  final String id;
  final String name;

  CategoryOption({
    required this.id,
    required this.name,
  });

  factory CategoryOption.fromJson(Map<String, dynamic> json) {
    return CategoryOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
