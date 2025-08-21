// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';

// // Shopping List Models
// class ShoppingList {
//   final String id;
//   final String userId;
//   final String title;
//   final List<ShoppingListItem> items;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   ShoppingList({
//     required this.id,
//     required this.userId,
//     required this.title,
//     this.items = const [],
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ShoppingList.fromJson(Map<String, dynamic> json) {
//     return ShoppingList(
//       id: json['id'] ?? '',
//       userId: json['userId'] ?? '',
//       title: json['title'] ?? '',
//       items: json['items'] != null 
//           ? (json['items'] as List).map((e) => ShoppingListItem.fromJson(e)).toList()
//           : [],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }

//   int get completedItems => items.where((item) => item.isCompleted).length;
//   int get totalItems => items.length;
//   double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;
//   bool get isCompleted => totalItems > 0 && completedItems == totalItems;
// }

// class ShoppingListItem {
//   final String id;
//   final String shoppingListId;
//   final String name;
//   final int quantity;
//   final bool isCompleted;
//   final String? notes;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   ShoppingListItem({
//     required this.id,
//     required this.shoppingListId,
//     required this.name,
//     this.quantity = 1,
//     this.isCompleted = false,
//     this.notes,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
//     return ShoppingListItem(
//       id: json['id'] ?? '',
//       shoppingListId: json['shoppingListId'] ?? '',
//       name: json['name'] ?? '',
//       quantity: json['quantity'] ?? 1,
//       isCompleted: json['isCompleted'] ?? false,
//       notes: json['notes'],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }
// }

// // Wishlist Models
// class WishlistItem {
//   final String id;
//   final String userId;
//   final String name;
//   final String? flyerItemId;
//   final double? targetPrice;
//   final double? currentPrice;
//   final bool isPriceAlert;
//   final String? imageUrl;
//   final String? storeName;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   WishlistItem({
//     required this.id,
//     required this.userId,
//     required this.name,
//     this.flyerItemId,
//     this.targetPrice,
//     this.currentPrice,
//     this.isPriceAlert = false,
//     this.imageUrl,
//     this.storeName,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory WishlistItem.fromJson(Map<String, dynamic> json) {
//     return WishlistItem(
//       id: json['id'] ?? '',
//       userId: json['userId'] ?? '',
//       name: json['name'] ?? '',
//       flyerItemId: json['flyerItemId'],
//       targetPrice: json['targetPrice']?.toDouble(),
//       currentPrice: json['currentPrice']?.toDouble(),
//       isPriceAlert: json['isPriceAlert'] ?? false,
//       imageUrl: json['imageUrl'],
//       storeName: json['storeName'],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }

//   bool get isPriceDropped {
//     if (targetPrice == null || currentPrice == null) return false;
//     return currentPrice! <= targetPrice!;
//   }

//   double? get savingsAmount {
//     if (targetPrice == null || currentPrice == null) return null;
//     return targetPrice! - currentPrice!;
//   }

//   double? get savingsPercentage {
//     if (targetPrice == null || currentPrice == null || targetPrice == 0) return null;
//     return ((targetPrice! - currentPrice!) / targetPrice!) * 100;
//   }
// }

// // Flyer Models
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
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final Store? store;

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
//     required this.createdAt,
//     required this.updatedAt,
//     this.store,
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
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       store: json['store'] != null ? Store.fromJson(json['store']) : null,
//     );
//   }

//   bool get isActive {
//     final now = DateTime.now();
//     return now.isAfter(startDate) && now.isBefore(endDate);
//   }

//   String get statusText {
//     final now = DateTime.now();
//     if (now.isBefore(startDate)) return 'Upcoming';
//     if (now.isAfter(endDate)) return 'Expired';
//     return 'Active';
//   }
// }

// // Coupon Models
// class Coupon {
//   final String id;
//   final String title;
//   final String storeId;
//   final String? code;
//   final String? barcodeUrl;
//   final String? qrCodeUrl;
//   final String discount;
//   final String? description;
//   final DateTime startDate;
//   final DateTime endDate;
//   final bool isOnline;
//   final bool isInStore;
//   final bool isPremium;
//   final double? price;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final Store? store;

//   Coupon({
//     required this.id,
//     required this.title,
//     required this.storeId,
//     this.code,
//     this.barcodeUrl,
//     this.qrCodeUrl,
//     required this.discount,
//     this.description,
//     required this.startDate,
//     required this.endDate,
//     this.isOnline = true,
//     this.isInStore = true,
//     this.isPremium = false,
//     this.price,
//     required this.createdAt,
//     required this.updatedAt,
//     this.store,
//   });

//   factory Coupon.fromJson(Map<String, dynamic> json) {
//     return Coupon(
//       id: json['id'] ?? '',
//       title: json['title'] ?? '',
//       storeId: json['storeId'] ?? '',
//       code: json['code'],
//       barcodeUrl: json['barcodeUrl'],
//       qrCodeUrl: json['qrCodeUrl'],
//       discount: json['discount'] ?? '',
//       description: json['description'],
//       startDate: DateTime.parse(json['startDate']),
//       endDate: DateTime.parse(json['endDate']),
//       isOnline: json['isOnline'] ?? true,
//       isInStore: json['isInStore'] ?? true,
//       isPremium: json['isPremium'] ?? false,
//       price: json['price']?.toDouble(),
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       store: json['store'] != null ? Store.fromJson(json['store']) : null,
//     );
//   }

//   bool get isActive {
//     final now = DateTime.now();
//     return now.isAfter(startDate) && now.isBefore(endDate);
//   }

//   String get statusText {
//     final now = DateTime.now();
//     if (now.isBefore(startDate)) return 'Upcoming';
//     if (now.isAfter(endDate)) return 'Expired';
//     return 'Active';
//   }
// }

// // Store Model
// class Store {
//   final String id;
//   final String name;
//   final String? logo;
//   final String? description;
//   final String? address;
//   final double? latitude;
//   final double? longitude;
//   final String? ownerId;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Store({
//     required this.id,
//     required this.name,
//     this.logo,
//     this.description,
//     this.address,
//     this.latitude,
//     this.longitude,
//     this.ownerId,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Store.fromJson(Map<String, dynamic> json) {
//     return Store(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       logo: json['logo'],
//       description: json['description'],
//       address: json['address'],
//       latitude: json['latitude']?.toDouble(),
//       longitude: json['longitude']?.toDouble(),
//       ownerId: json['ownerId'],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }
// }

// // SavedTab Widget
// class SavedTab extends ConsumerStatefulWidget {
//   const SavedTab({super.key});

//   @override
//   ConsumerState<SavedTab> createState() => _SavedTabState();
// }

// class _SavedTabState extends ConsumerState<SavedTab> with TickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Tab Bar
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: TabBar(
//             controller: _tabController,
//             labelColor: const Color(0xFF6366F1),
//             unselectedLabelColor: Colors.grey[600],
//             indicatorColor: const Color(0xFF6366F1),
//             isScrollable: true,
//             tabAlignment: TabAlignment.center,
//             tabs: const [
//               Tab(text: 'Shopping Lists'),
//               Tab(text: 'Wishlist'),
//               Tab(text: 'Saved Flyers'),
//               Tab(text: 'Saved Coupons'),
//             ],
//           ),
//         ),
        
//         // Tab Views
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: const [
//               ShoppingListsView(),
//               WishlistView(),
//               SavedFlyersView(),
//               SavedCouponsView(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Complete the _deleteShoppingList method
// Future<void> _deleteShoppingList(BuildContext context, WidgetRef ref, ShoppingList list) async {
//   final confirmed = await showDialog<bool>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Delete Shopping List'),
//       content: Text('Are you sure you want to delete "${list.title}"? This action cannot be undone.'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context, false),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context, true),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           child: const Text('Delete', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );

//   if (confirmed == true) {
//     try {
//       final user = ref.read(currentBackendUserProvider);
//       if (user != null) {
//         final service = ref.read(savedItemsServiceProvider);
//         final success = await service.deleteShoppingList(list.id, user.email);
        
//         if (success) {
//           ref.invalidate(shoppingListsProvider);
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Shopping list deleted successfully'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//         } else {
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Failed to delete shopping list'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }

// // Utility function for date formatting
// String _formatRelativeDate(DateTime date) {
//   final now = DateTime.now();
//   final difference = now.difference(date);

//   if (difference.inDays > 7) {
//     return '${difference.inDays} days ago';
//   } else if (difference.inDays > 0) {
//     return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
//   } else if (difference.inHours > 0) {
//     return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
//   } else if (difference.inMinutes > 0) {
//     return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
//   } else {
//     return 'Just now';
//   }
// }