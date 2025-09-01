// // lib/features/flyers/models/flyer_models.dart

// import 'package:topprix/features/home/user_home/services/categories_service.dart';
// import 'package:topprix/features/home/user_home/services/store_service.dart';

// // Flyer Model
// class Flyer {
//   final String id;
//   final String title;
//   final String storeId;
//   final String imageUrl;
//   final DateTime startDate;
//   final DateTime endDate;
//   final bool isSponsored;
//   final bool isPremium;
//   final double? price;
//   final bool isPaid;
//   final Store? store;
//   final List<Category> categories;
//   final List<FlyerItem> items;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Flyer({
//     required this.id,
//     required this.title,
//     required this.storeId,
//     required this.imageUrl,
//     required this.startDate,
//     required this.endDate,
//     this.isSponsored = false,
//     this.isPremium = false,
//     this.price,
//     this.isPaid = false,
//     this.store,
//     this.categories = const [],
//     this.items = const [],
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Flyer.fromJson(Map<String, dynamic> json) {
//     return Flyer(
//       id: json['id'] ?? '',
//       title: json['title'] ?? '',
//       storeId: json['storeId'] ?? '',
//       imageUrl: json['imageUrl'] ?? '',
//       startDate: DateTime.parse(json['startDate']),
//       endDate: DateTime.parse(json['endDate']),
//       isSponsored: json['isSponsored'] ?? false,
//       isPremium: json['isPremium'] ?? false,
//       price: json['price']?.toDouble(),
//       isPaid: json['isPaid'] ?? false,
//       store: json['store'] != null ? Store.fromJson(json['store']) : null,
//       categories: json['categories'] != null
//           ? (json['categories'] as List)
//               .map((e) => Category.fromJson(e))
//               .toList()
//           : [],
//       items: json['items'] != null
//           ? (json['items'] as List).map((e) => FlyerItem.fromJson(e)).toList()
//           : [],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'storeId': storeId,
//       'imageUrl': imageUrl,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'isSponsored': isSponsored,
//       'isPremium': isPremium,
//       'price': price,
//       'isPaid': isPaid,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }

//   bool get isActive {
//     final now = DateTime.now();
//     return now.isAfter(startDate) && now.isBefore(endDate) && isPaid;
//   }
// }

// // Flyer Item Model
// class FlyerItem {
//   final String id;
//   final String flyerId;
//   final String name;
//   final double price;
//   final double? oldPrice;
//   final String? imageUrl;
//   final String? description;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   FlyerItem({
//     required this.id,
//     required this.flyerId,
//     required this.name,
//     required this.price,
//     this.oldPrice,
//     this.imageUrl,
//     this.description,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory FlyerItem.fromJson(Map<String, dynamic> json) {
//     return FlyerItem(
//       id: json['id'] ?? '',
//       flyerId: json['flyerId'] ?? '',
//       name: json['name'] ?? '',
//       price: (json['price'] ?? 0.0).toDouble(),
//       oldPrice: json['oldPrice']?.toDouble(),
//       imageUrl: json['imageUrl'],
//       description: json['description'],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'flyerId': flyerId,
//       'name': name,
//       'price': price,
//       'oldPrice': oldPrice,
//       'imageUrl': imageUrl,
//       'description': description,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }

//   double? get discount {
//     if (oldPrice != null && oldPrice! > price) {
//       return ((oldPrice! - price) / oldPrice!) * 100;
//     }
//     return null;
//   }
// }

// // Create Flyer Request Model
// class CreateFlyerRequest {
//   final String title;
//   final String storeId;
//   final String imageUrl;
//   final DateTime startDate;
//   final DateTime endDate;
//   final List<String> categoryIds;


//   CreateFlyerRequest({
//     required this.title,
//     required this.storeId,
//     required this.imageUrl,
//     required this.startDate,
//     required this.endDate,
//     this.categoryIds = const [],
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'storeId': storeId,
//       'imageUrl': imageUrl,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'categoryIds': categoryIds,
//     };
//   }
// }

// // Create Flyer Response Model
// class CreateFlyerResponse {
//   final String message;
//   final Flyer flyer;
//   final bool requiresPayment;
//   final double? paymentAmount;
//   final String? currency;
//   final String? paymentType;
//   final String? paymentInstructions;

//   CreateFlyerResponse({
//     required this.message,
//     required this.flyer,
//     this.requiresPayment = false,
//     this.paymentAmount,
//     this.currency,
//     this.paymentType,
//     this.paymentInstructions,
//   });

//   factory CreateFlyerResponse.fromJson(Map<String, dynamic> json) {
//     return CreateFlyerResponse(
//       message: json['message'] ?? '',
//       flyer: Flyer.fromJson(json['flyer']),
//       requiresPayment: json['requiresPayment'] ?? false,
//       paymentAmount: json['paymentAmount']?.toDouble(),
//       currency: json['currency'],
//       paymentType: json['paymentType'],
//       paymentInstructions: json['paymentInstructions'],
//     );
//   }
// }

// // Get Flyers Response Model
// class GetFlyersResponse {
//   final List<Flyer> flyers;
//   final Pagination? pagination;

//   GetFlyersResponse({
//     required this.flyers,
//     this.pagination,
//   });

//   factory GetFlyersResponse.fromJson(Map<String, dynamic> json) {
//     return GetFlyersResponse(
//       flyers:
//           (json['flyers'] as List?)?.map((e) => Flyer.fromJson(e)).toList() ??
//               [],
//       pagination: json['pagination'] != null
//           ? Pagination.fromJson(json['pagination'])
//           : null,
//     );
//   }
// }

// // Pagination Model
// class Pagination {
//   final int total;
//   final int limit;
//   final int offset;

//   Pagination({
//     required this.total,
//     required this.limit,
//     required this.offset,
//   });

//   factory Pagination.fromJson(Map<String, dynamic> json) {
//     return Pagination(
//       total: json['total'] ?? 0,
//       limit: json['limit'] ?? 0,
//       offset: json['offset'] ?? 0,
//     );
//   }

//   int get currentPage => (offset ~/ limit) + 1;
//   int get totalPages => (total / limit).ceil();
//   bool get hasNextPage => offset + limit < total;
//   bool get hasPreviousPage => offset > 0;
// }

// // Add Flyer Item Request Model
// class AddFlyerItemRequest {
//   final String flyerId;
//   final String name;
//   final double price;
//   final double? oldPrice;
//   final String? imageUrl;
//   final String? description;

//   AddFlyerItemRequest({
//     required this.flyerId,
//     required this.name,
//     required this.price,
//     this.oldPrice,
//     this.imageUrl,
//     this.description,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'flyerId': flyerId,
//       'name': name,
//       'price': price,
//       'oldPrice': oldPrice,
//       'imageUrl': imageUrl,
//       'description': description,
//     };
//   }
// }

// // Save Flyer Request Model
// class SaveFlyerRequest {
//   final String userId;
//   final String flyerId;

//   SaveFlyerRequest({
//     required this.userId,
//     required this.flyerId,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'flyerId': flyerId,
//     };
//   }
// }
