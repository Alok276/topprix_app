class FlyerItemModel {
  final String id;
  final String name;
  final String? description;
  final double? originalPrice;
  final double? salePrice;
  final String? imageUrl;
  final String flyerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlyerItemModel({
    required this.id,
    required this.name,
    this.description,
    this.originalPrice,
    this.salePrice,
    this.imageUrl,
    required this.flyerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlyerItemModel.fromJson(Map<String, dynamic> json) {
    return FlyerItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      originalPrice: json['originalPrice']?.toDouble(),
      salePrice: json['salePrice']?.toDouble(),
      imageUrl: json['imageUrl'],
      flyerId: json['flyerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'originalPrice': originalPrice,
      'salePrice': salePrice,
      'imageUrl': imageUrl,
      'flyerId': flyerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  double? get discountAmount {
    if (originalPrice == null || salePrice == null) return null;
    return originalPrice! - salePrice!;
  }

  double? get discountPercentage {
    if (originalPrice == null || salePrice == null) return null;
    return ((originalPrice! - salePrice!) / originalPrice!) * 100;
  }

  String get formattedDiscount {
    final percentage = discountPercentage;
    if (percentage == null) return '';
    return '${percentage.toStringAsFixed(0)}% OFF';
  }
}
