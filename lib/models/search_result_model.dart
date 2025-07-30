class SearchResultsModel {
  final List<SearchResult> results;
  final int totalResults;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final SearchSummary? summary;
  final List<SearchFilter>? appliedFilters;
  final String? searchId;
  final DateTime timestamp;

  SearchResultsModel({
    required this.results,
    required this.totalResults,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.summary,
    this.appliedFilters,
    this.searchId,
    required this.timestamp,
  });

  factory SearchResultsModel.fromJson(Map<String, dynamic> json) {
    return SearchResultsModel(
      results: (json['results'] as List? ?? [])
          .map((item) => SearchResult.fromJson(item))
          .toList(),
      totalResults: json['totalResults'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      summary: json['summary'] != null
          ? SearchSummary.fromJson(json['summary'])
          : null,
      appliedFilters: (json['appliedFilters'] as List? ?? [])
          .map((filter) => SearchFilter.fromJson(filter))
          .toList(),
      searchId: json['searchId'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((result) => result.toJson()).toList(),
      'totalResults': totalResults,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
      'summary': summary?.toJson(),
      'appliedFilters':
          appliedFilters?.map((filter) => filter.toJson()).toList(),
      'searchId': searchId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SearchResult {
  final String id;
  final String type; // 'flyer', 'coupon', 'store', 'deal'
  final String title;
  final String? description;
  final String? imageUrl;
  final String store;
  final String? storeId;
  final String? category;
  final String? categoryId;
  final String? discount;
  final double? originalPrice;
  final double? salePrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? distance;
  final String? address;
  final bool isActive;
  final bool isFeatured;
  final double? rating;
  final int? reviewCount;
  final Map<String, dynamic>? metadata;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    required this.store,
    this.storeId,
    this.category,
    this.categoryId,
    this.discount,
    this.originalPrice,
    this.salePrice,
    this.startDate,
    this.endDate,
    this.distance,
    this.address,
    this.isActive = true,
    this.isFeatured = false,
    this.rating,
    this.reviewCount,
    this.metadata,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      store: json['store'] ?? '',
      storeId: json['storeId'],
      category: json['category'],
      categoryId: json['categoryId'],
      discount: json['discount'],
      originalPrice: json['originalPrice']?.toDouble(),
      salePrice: json['salePrice']?.toDouble(),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      distance: json['distance']?.toDouble(),
      address: json['address'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'store': store,
      'storeId': storeId,
      'category': category,
      'categoryId': categoryId,
      'discount': discount,
      'originalPrice': originalPrice,
      'salePrice': salePrice,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'distance': distance,
      'address': address,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'rating': rating,
      'reviewCount': reviewCount,
      'metadata': metadata,
    };
  }
}

class SearchSummary {
  final int totalFlyers;
  final int totalCoupons;
  final int totalStores;
  final int totalDeals;
  final String? bestDiscount;
  final String? nearestStore;
  final int expiringCount; // deals expiring soon

  SearchSummary({
    required this.totalFlyers,
    required this.totalCoupons,
    required this.totalStores,
    required this.totalDeals,
    this.bestDiscount,
    this.nearestStore,
    required this.expiringCount,
  });

  factory SearchSummary.fromJson(Map<String, dynamic> json) {
    return SearchSummary(
      totalFlyers: json['totalFlyers'] ?? 0,
      totalCoupons: json['totalCoupons'] ?? 0,
      totalStores: json['totalStores'] ?? 0,
      totalDeals: json['totalDeals'] ?? 0,
      bestDiscount: json['bestDiscount'],
      nearestStore: json['nearestStore'],
      expiringCount: json['expiringCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFlyers': totalFlyers,
      'totalCoupons': totalCoupons,
      'totalStores': totalStores,
      'totalDeals': totalDeals,
      'bestDiscount': bestDiscount,
      'nearestStore': nearestStore,
      'expiringCount': expiringCount,
    };
  }
}

class SearchFilter {
  final String key;
  final String label;
  final dynamic value;
  final String type; // 'text', 'range', 'selection', 'boolean'

  SearchFilter({
    required this.key,
    required this.label,
    required this.value,
    required this.type,
  });

  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      value: json['value'],
      type: json['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'value': value,
      'type': type,
    };
  }
}

// Additional models for search functionality

class SearchFilters {
  final String? categoryId;
  final String? storeId;
  final double? minDiscount;
  final double? maxDiscount;
  final double? maxDistance;
  final bool? isOnline;
  final bool? isInStore;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<String>? contentTypes;

  SearchFilters({
    this.categoryId,
    this.storeId,
    this.minDiscount,
    this.maxDiscount,
    this.maxDistance,
    this.isOnline,
    this.isInStore,
    this.startDate,
    this.endDate,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.contentTypes,
  });

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      categoryId: json['categoryId'],
      storeId: json['storeId'],
      minDiscount: json['minDiscount']?.toDouble(),
      maxDiscount: json['maxDiscount']?.toDouble(),
      maxDistance: json['maxDistance']?.toDouble(),
      isOnline: json['isOnline'],
      isInStore: json['isInStore'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      minRating: json['minRating']?.toDouble(),
      contentTypes: json['contentTypes'] != null
          ? List<String>.from(json['contentTypes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'storeId': storeId,
      'minDiscount': minDiscount,
      'maxDiscount': maxDiscount,
      'maxDistance': maxDistance,
      'isOnline': isOnline,
      'isInStore': isInStore,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
      'contentTypes': contentTypes,
    };
  }
}

class SearchSort {
  final String field;
  final SortOrder order;

  SearchSort({
    required this.field,
    required this.order,
  });

  factory SearchSort.fromJson(Map<String, dynamic> json) {
    return SearchSort(
      field: json['field'] ?? 'relevance',
      order: SortOrder.values.firstWhere(
        (e) => e.name == json['order'],
        orElse: () => SortOrder.desc,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'order': order.name,
    };
  }
}

enum SortOrder { asc, desc }

class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  final int resultCount;
  final String? category;

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
    required this.resultCount,
    this.category,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      resultCount: json['resultCount'] ?? 0,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
      'category': category,
    };
  }
}

class TrendingSearch {
  final String query;
  final int searchCount;
  final double trendScore;
  final String? category;

  TrendingSearch({
    required this.query,
    required this.searchCount,
    required this.trendScore,
    this.category,
  });

  factory TrendingSearch.fromJson(Map<String, dynamic> json) {
    return TrendingSearch(
      query: json['query'] ?? '',
      searchCount: json['searchCount'] ?? 0,
      trendScore: json['trendScore']?.toDouble() ?? 0.0,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'searchCount': searchCount,
      'trendScore': trendScore,
      'category': category,
    };
  }
}

class SavedSearch {
  final String id;
  final String name;
  final String query;
  final SearchFilters? filters;
  final bool enableNotifications;
  final DateTime createdAt;
  final DateTime? lastExecuted;

  SavedSearch({
    required this.id,
    required this.name,
    required this.query,
    this.filters,
    required this.enableNotifications,
    required this.createdAt,
    this.lastExecuted,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      query: json['query'] ?? '',
      filters: json['filters'] != null
          ? SearchFilters.fromJson(json['filters'])
          : null,
      enableNotifications: json['enableNotifications'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastExecuted: json['lastExecuted'] != null
          ? DateTime.parse(json['lastExecuted'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'query': query,
      'filters': filters?.toJson(),
      'enableNotifications': enableNotifications,
      'createdAt': createdAt.toIso8601String(),
      'lastExecuted': lastExecuted?.toIso8601String(),
    };
  }
}

class SearchAnalytics {
  final int totalSearches;
  final List<String> topQueries;
  final Map<String, int> searchesByCategory;
  final double averageResultsPerSearch;
  final int clickThroughRate;

  SearchAnalytics({
    required this.totalSearches,
    required this.topQueries,
    required this.searchesByCategory,
    required this.averageResultsPerSearch,
    required this.clickThroughRate,
  });

  factory SearchAnalytics.fromJson(Map<String, dynamic> json) {
    return SearchAnalytics(
      totalSearches: json['totalSearches'] ?? 0,
      topQueries: List<String>.from(json['topQueries'] ?? []),
      searchesByCategory:
          Map<String, int>.from(json['searchesByCategory'] ?? {}),
      averageResultsPerSearch:
          json['averageResultsPerSearch']?.toDouble() ?? 0.0,
      clickThroughRate: json['clickThroughRate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSearches': totalSearches,
      'topQueries': topQueries,
      'searchesByCategory': searchesByCategory,
      'averageResultsPerSearch': averageResultsPerSearch,
      'clickThroughRate': clickThroughRate,
    };
  }
}
