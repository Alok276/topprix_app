import 'package:topprix/models/coupon_model.dart';
import 'package:topprix/models/flyer_model.dart';

class StoreModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? imageUrl;
  final Map<String, String>? openingHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance; // For location-based queries

  StoreModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.imageUrl,
    this.openingHours,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      imageUrl: json['imageUrl'],
      openingHours: json['openingHours'] != null
          ? Map<String, String>.from(json['openingHours'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'imageUrl': imageUrl,
      'openingHours': openingHours,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'distance': distance,
    };
  }

  // Helper methods
  String get fullAddress {
    final parts = [address, city, state, postalCode, country]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)}m away';
    }
    return '${distance!.toStringAsFixed(1)}km away';
  }
}

class StoreWithDealsModel {
  final StoreModel store;
  final int activeFlyers;
  final int activeCoupons;
  final int totalDeals;

  StoreWithDealsModel({
    required this.store,
    required this.activeFlyers,
    required this.activeCoupons,
    required this.totalDeals,
  });

  factory StoreWithDealsModel.fromJson(Map<String, dynamic> json) {
    return StoreWithDealsModel(
      store: StoreModel.fromJson(json['store']),
      activeFlyers: json['activeFlyers'] ?? 0,
      activeCoupons: json['activeCoupons'] ?? 0,
      totalDeals: json['totalDeals'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store': store.toJson(),
      'activeFlyers': activeFlyers,
      'activeCoupons': activeCoupons,
      'totalDeals': totalDeals,
    };
  }
}

class StoreDealsModel {
  final List<FlyerModel> flyers;
  final List<CouponModel> coupons;
  final int totalFlyers;
  final int totalCoupons;

  StoreDealsModel({
    required this.flyers,
    required this.coupons,
    required this.totalFlyers,
    required this.totalCoupons,
  });

  factory StoreDealsModel.fromJson(Map<String, dynamic> json) {
    return StoreDealsModel(
      flyers: (json['flyers'] as List)
          .map((flyer) => FlyerModel.fromJson(flyer))
          .toList(),
      coupons: (json['coupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon))
          .toList(),
      totalFlyers: json['totalFlyers'] ?? 0,
      totalCoupons: json['totalCoupons'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flyers': flyers.map((flyer) => flyer.toJson()).toList(),
      'coupons': coupons.map((coupon) => coupon.toJson()).toList(),
      'totalFlyers': totalFlyers,
      'totalCoupons': totalCoupons,
    };
  }
}

class HolidayHours {
  final String date;
  final String hours;
  final bool isClosed;

  HolidayHours({
    required this.date,
    required this.hours,
    required this.isClosed,
  });

  factory HolidayHours.fromJson(Map<String, dynamic> json) {
    return HolidayHours(
      date: json['date'],
      hours: json['hours'] ?? '',
      isClosed: json['isClosed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'hours': hours,
      'isClosed': isClosed,
    };
  }
}

class StoreReviewsModel {
  final List<StoreReview> reviews;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  StoreReviewsModel({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory StoreReviewsModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewsModel(
      reviews: (json['reviews'] as List)
          .map((review) => StoreReview.fromJson(review))
          .toList(),
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
    };
  }
}

class StoreReview {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String? review;
  final List<String> photos;
  final DateTime createdAt;

  StoreReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.review,
    required this.photos,
    required this.createdAt,
  });

  factory StoreReview.fromJson(Map<String, dynamic> json) {
    return StoreReview(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Anonymous',
      rating: json['rating'],
      review: json['review'],
      photos: List<String>.from(json['photos'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'review': review,
      'photos': photos,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class StoreRatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;

  StoreRatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  factory StoreRatingSummary.fromJson(Map<String, dynamic> json) {
    return StoreRatingSummary(
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      ratingCounts: Map<int, int>.from(json['ratingCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingCounts': ratingCounts,
    };
  }
}

class StoreStatsModel {
  final int totalViews;
  final int totalFlyers;
  final int totalCoupons;
  final int totalFavorites;
  final double averageRating;
  final int totalReviews;

  StoreStatsModel({
    required this.totalViews,
    required this.totalFlyers,
    required this.totalCoupons,
    required this.totalFavorites,
    required this.averageRating,
    required this.totalReviews,
  });

  factory StoreStatsModel.fromJson(Map<String, dynamic> json) {
    return StoreStatsModel(
      totalViews: json['totalViews'] ?? 0,
      totalFlyers: json['totalFlyers'] ?? 0,
      totalCoupons: json['totalCoupons'] ?? 0,
      totalFavorites: json['totalFavorites'] ?? 0,
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalViews': totalViews,
      'totalFlyers': totalFlyers,
      'totalCoupons': totalCoupons,
      'totalFavorites': totalFavorites,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}

class StoreAnalyticsModel {
  final Map<String, int> viewsByDay;
  final Map<String, int> dealInteractions;
  final int totalUniqueVisitors;
  final double conversionRate;
  final List<Map<String, dynamic>> topPerformingDeals;

  StoreAnalyticsModel({
    required this.viewsByDay,
    required this.dealInteractions,
    required this.totalUniqueVisitors,
    required this.conversionRate,
    required this.topPerformingDeals,
  });

  factory StoreAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return StoreAnalyticsModel(
      viewsByDay: Map<String, int>.from(json['viewsByDay'] ?? {}),
      dealInteractions: Map<String, int>.from(json['dealInteractions'] ?? {}),
      totalUniqueVisitors: json['totalUniqueVisitors'] ?? 0,
      conversionRate: json['conversionRate']?.toDouble() ?? 0.0,
      topPerformingDeals:
          List<Map<String, dynamic>>.from(json['topPerformingDeals'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewsByDay': viewsByDay,
      'dealInteractions': dealInteractions,
      'totalUniqueVisitors': totalUniqueVisitors,
      'conversionRate': conversionRate,
      'topPerformingDeals': topPerformingDeals,
    };
  }
}

class DirectionsModel {
  final double distance;
  final String duration;
  final List<DirectionStep> steps;
  final String polyline;

  DirectionsModel({
    required this.distance,
    required this.duration,
    required this.steps,
    required this.polyline,
  });

  factory DirectionsModel.fromJson(Map<String, dynamic> json) {
    return DirectionsModel(
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration'] ?? '',
      steps: (json['steps'] as List)
          .map((step) => DirectionStep.fromJson(step))
          .toList(),
      polyline: json['polyline'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'duration': duration,
      'steps': steps.map((step) => step.toJson()).toList(),
      'polyline': polyline,
    };
  }
}

class DirectionStep {
  final String instruction;
  final double distance;
  final String duration;

  DirectionStep({
    required this.instruction,
    required this.distance,
    required this.duration,
  });

  factory DirectionStep.fromJson(Map<String, dynamic> json) {
    return DirectionStep(
      instruction: json['instruction'] ?? '',
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'distance': distance,
      'duration': duration,
    };
  }
}
