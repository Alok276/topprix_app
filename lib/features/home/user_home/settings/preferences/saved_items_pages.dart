import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:topprix/theme/app_theme.dart';

// Data Models (matching your API structure)
class ShoppingList {
  final String id;
  final String userId;
  final String title;
  final List<ShoppingListItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingList({
    required this.id,
    required this.userId,
    required this.title,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => ShoppingListItem.fromJson(item))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  int get completedItems => items.where((item) => item.isCompleted).length;
  int get totalItems => items.length;
  double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;
  bool get isCompleted => totalItems > 0 && completedItems == totalItems;
}

class ShoppingListItem {
  final String id;
  final String name;
  final int quantity;
  final bool isCompleted;
  final String? notes;

  ShoppingListItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.isCompleted = false,
    this.notes,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }
}

class WishlistItem {
  final String id;
  final String name;
  final double? targetPrice;
  final double? currentPrice;
  final String? imageUrl;
  final String? storeName;
  final bool isPriceAlert;

  WishlistItem({
    required this.id,
    required this.name,
    this.targetPrice,
    this.currentPrice,
    this.imageUrl,
    this.storeName,
    this.isPriceAlert = false,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      targetPrice: json['targetPrice']?.toDouble(),
      currentPrice: json['currentPrice']?.toDouble(),
      imageUrl: json['imageUrl'],
      storeName: json['storeName'],
      isPriceAlert: json['isPriceAlert'] ?? false,
    );
  }

  bool get isPriceDropped {
    if (targetPrice == null || currentPrice == null) return false;
    return currentPrice! <= targetPrice!;
  }
}

class SavedFlyer {
  final String id;
  final String title;
  final String storeName;
  final String imageUrl;
  final DateTime endDate;
  final bool isExpired;

  SavedFlyer({
    required this.id,
    required this.title,
    required this.storeName,
    required this.imageUrl,
    required this.endDate,
    required this.isExpired,
  });

  factory SavedFlyer.fromJson(Map<String, dynamic> json) {
    return SavedFlyer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      storeName: json['storeName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      endDate: DateTime.parse(json['endDate']),
      isExpired: json['isExpired'] ?? false,
    );
  }
}

class SavedCoupon {
  final String id;
  final String title;
  final String storeName;
  final String discount;
  final DateTime endDate;
  final bool isExpired;
  final bool isUsed;

  SavedCoupon({
    required this.id,
    required this.title,
    required this.storeName,
    required this.discount,
    required this.endDate,
    required this.isExpired,
    this.isUsed = false,
  });

  factory SavedCoupon.fromJson(Map<String, dynamic> json) {
    return SavedCoupon(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      storeName: json['storeName'] ?? '',
      discount: json['discount'] ?? '',
      endDate: DateTime.parse(json['endDate']),
      isExpired: json['isExpired'] ?? false,
      isUsed: json['isUsed'] ?? false,
    );
  }
}

// API Service
class SavedItemsService {
  final Dio _dio;

  SavedItemsService(this._dio);

  // Shopping Lists
  Future<List<ShoppingList>> getShoppingLists(String userEmail) async {
    try {
      final response = await _dio.get(
        '/shopping-lists',
        options: Options(headers: {'user-email': userEmail}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> lists = response.data['lists'] ?? [];
        return lists.map((json) => ShoppingList.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching shopping lists: $e');
      return [];
    }
  }

  Future<bool> createShoppingList({
    required String title,
    required String userEmail,
  }) async {
    try {
      final response = await _dio.post(
        '/shopping-list',
        data: {'title': title},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating shopping list: $e');
      return false;
    }
  }

  // Wishlist
  Future<List<WishlistItem>> getWishlistItems(String userEmail) async {
    try {
      final response = await _dio.get(
        '/wishlist',
        options: Options(headers: {'user-email': userEmail}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'] ?? [];
        return items.map((json) => WishlistItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching wishlist: $e');
      return [];
    }
  }

  // Saved Flyers
  Future<List<SavedFlyer>> getSavedFlyers(String userEmail) async {
    try {
      final response = await _dio.get(
        '/saved-flyers',
        options: Options(headers: {'user-email': userEmail}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> flyers = response.data['flyers'] ?? [];
        return flyers.map((json) => SavedFlyer.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching saved flyers: $e');
      return [];
    }
  }

  // Saved Coupons
  Future<List<SavedCoupon>> getSavedCoupons(String userEmail) async {
    try {
      final response = await _dio.get(
        '/saved-coupons',
        options: Options(headers: {'user-email': userEmail}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> coupons = response.data['coupons'] ?? [];
        return coupons.map((json) => SavedCoupon.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching saved coupons: $e');
      return [];
    }
  }
}

// Providers
final savedItemsServiceProvider = Provider<SavedItemsService>((ref) {
  final dio = ref.read(dioProvider); // Assuming you have dioProvider
  return SavedItemsService(dio);
});

final shoppingListsProvider =
    FutureProvider.family<List<ShoppingList>, String>((ref, userEmail) async {
  final service = ref.read(savedItemsServiceProvider);
  return service.getShoppingLists(userEmail);
});

final wishlistProvider =
    FutureProvider.family<List<WishlistItem>, String>((ref, userEmail) async {
  final service = ref.read(savedItemsServiceProvider);
  return service.getWishlistItems(userEmail);
});

final savedFlyersProvider =
    FutureProvider.family<List<SavedFlyer>, String>((ref, userEmail) async {
  final service = ref.read(savedItemsServiceProvider);
  return service.getSavedFlyers(userEmail);
});

final savedCouponsProvider =
    FutureProvider.family<List<SavedCoupon>, String>((ref, userEmail) async {
  final service = ref.read(savedItemsServiceProvider);
  return service.getSavedCoupons(userEmail);
});

// Main Page Widget
class SavedItemsPage extends ConsumerStatefulWidget {
  const SavedItemsPage({super.key});

  @override
  ConsumerState<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends ConsumerState<SavedItemsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Get user email from your auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState =
          ref.read(topPrixAuthProvider); // Adjust to your auth provider
      setState(() {
        userEmail = authState.backendUser?.email;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userEmail == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart, size: 16),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final listsAsync =
                          ref.watch(shoppingListsProvider(userEmail!));
                      final count = listsAsync.when(
                        data: (lists) => lists.length,
                        loading: () => 0,
                        error: (_, __) => 0,
                      );
                      return Text('Lists ($count)');
                    },
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 16),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final wishlistAsync =
                          ref.watch(wishlistProvider(userEmail!));
                      final count = wishlistAsync.when(
                        data: (items) => items.length,
                        loading: () => 0,
                        error: (_, __) => 0,
                      );
                      return Text('Wishlist ($count)');
                    },
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer, size: 16),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final flyersAsync =
                          ref.watch(savedFlyersProvider(userEmail!));
                      final count = flyersAsync.when(
                        data: (flyers) => flyers.length,
                        loading: () => 0,
                        error: (_, __) => 0,
                      );
                      return Text('Flyers ($count)');
                    },
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.confirmation_number, size: 16),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final couponsAsync =
                          ref.watch(savedCouponsProvider(userEmail!));
                      final count = couponsAsync.when(
                        data: (coupons) => coupons.length,
                        loading: () => 0,
                        error: (_, __) => 0,
                      );
                      return Text('Coupons ($count)');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShoppingListsView(),
          _buildWishlistView(),
          _buildSavedFlyersView(),
          _buildSavedCouponsView(),
        ],
      ),
    );
  }

  Widget _buildShoppingListsView() {
    return Consumer(
      builder: (context, ref, child) {
        final listsAsync = ref.watch(shoppingListsProvider(userEmail!));

        return listsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text('Error loading shopping lists: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(shoppingListsProvider(userEmail!)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (lists) => RefreshIndicator(
            onRefresh: () async {
              ref.refresh(shoppingListsProvider(userEmail!));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shopping Lists',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _createNewShoppingList(),
                          icon: const Icon(Icons.add),
                          label: const Text('New List'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.surfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (lists.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyShoppingLists(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final list = lists[index];
                        return _buildShoppingListCard(list);
                      },
                      childCount: lists.length,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistView() {
    return Consumer(
      builder: (context, ref, child) {
        final wishlistAsync = ref.watch(wishlistProvider(userEmail!));

        return wishlistAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text('Error loading wishlist: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(wishlistProvider(userEmail!)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () async {
              ref.refresh(wishlistProvider(userEmail!));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Wishlist',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _addToWishlist(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: AppTheme.surfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverFillRemaining(child: _buildEmptyWishlist())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return _buildWishlistItemCard(item);
                      },
                      childCount: items.length,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedFlyersView() {
    return Consumer(
      builder: (context, ref, child) {
        final flyersAsync = ref.watch(savedFlyersProvider(userEmail!));

        return flyersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text('Error loading saved flyers: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(savedFlyersProvider(userEmail!)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (flyers) => RefreshIndicator(
            onRefresh: () async {
              ref.refresh(savedFlyersProvider(userEmail!));
            },
            child: _buildFlyersContent(flyers),
          ),
        );
      },
    );
  }

  Widget _buildSavedCouponsView() {
    return Consumer(
      builder: (context, ref, child) {
        final couponsAsync = ref.watch(savedCouponsProvider(userEmail!));

        return couponsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text('Error loading saved coupons: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(savedCouponsProvider(userEmail!)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (coupons) => RefreshIndicator(
            onRefresh: () async {
              ref.refresh(savedCouponsProvider(userEmail!));
            },
            child: _buildCouponsContent(coupons),
          ),
        );
      },
    );
  }

  // Keep all your existing build methods for cards and empty states...
  Widget _buildShoppingListCard(ShoppingList list) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openShoppingList(list),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleListAction(list, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'share', child: Text('Share')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${list.completedItems} of ${list.totalItems} items completed',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: list.progress,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                'Created ${_formatDate(list.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistItemCard(WishlistItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: item.isPriceDropped
            ? Border.all(color: AppTheme.successColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.storeName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.storeName!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (item.currentPrice != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.isPriceDropped
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '\$${item.currentPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: item.isPriceDropped
                                    ? AppTheme.successColor
                                    : Colors.black,
                              ),
                            ),
                          ),
                        if (item.targetPrice != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Target: \$${item.targetPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (item.isPriceDropped) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_down,
                                size: 14, color: AppTheme.successColor),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Price Drop Alert! 🎉',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              SizedBox(
                width: 40,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  onSelected: (value) => _handleWishlistAction(item, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Edit Alert')),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuItem(value: 'remove', child: Text('Remove')),
                  ],
                  child: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlyersContent(List<SavedFlyer> flyers) {
    final activeFlyers = flyers.where((f) => !f.isExpired).toList();
    final expiredFlyers = flyers.where((f) => f.isExpired).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Saved Flyers (${flyers.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (activeFlyers.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Active Deals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildFlyerCard(activeFlyers[index]),
                childCount: activeFlyers.length,
              ),
            ),
          ),
        ],
        if (expiredFlyers.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Expired Deals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildFlyerCard(expiredFlyers[index], isExpired: true),
                childCount: expiredFlyers.length,
              ),
            ),
          ),
        ],
        if (flyers.isEmpty)
          SliverFillRemaining(child: _buildEmptySavedFlyers()),
      ],
    );
  }

  Widget _buildCouponsContent(List<SavedCoupon> coupons) {
    final activeCoupons =
        coupons.where((c) => !c.isExpired && !c.isUsed).toList();
    final usedCoupons = coupons.where((c) => c.isUsed).toList();
    final expiredCoupons = coupons.where((c) => c.isExpired).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Saved Coupons (${coupons.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (activeCoupons.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ready to Use',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCouponCard(activeCoupons[index]),
              childCount: activeCoupons.length,
            ),
          ),
        ],
        if (usedCoupons.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Used Coupons',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildCouponCard(usedCoupons[index], isUsed: true),
              childCount: usedCoupons.length,
            ),
          ),
        ],
        if (coupons.isEmpty)
          SliverFillRemaining(child: _buildEmptySavedCoupons()),
      ],
    );
  }

  Widget _buildFlyerCard(SavedFlyer flyer, {bool isExpired = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Flyer Image
            Container(
              color: Colors.grey[200],
              child: flyer.imageUrl.isNotEmpty
                  ? Image.network(
                      flyer.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                              child: Icon(Icons.image,
                                  size: 40, color: Colors.grey)),
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey)),
            ),

            // Overlay for expired flyers
            if (isExpired)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    'EXPIRED',
                    style: TextStyle(
                      color: AppTheme.surfaceColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Bottom Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flyer.title,
                      style: const TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flyer.storeName,
                      style: const TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isExpired
                          ? 'Expired'
                          : 'Ends ${_formatDate(flyer.endDate)}',
                      style: const TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Remove button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeSavedFlyer(flyer),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppTheme.surfaceColor,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(SavedCoupon coupon,
      {bool isUsed = false, bool isExpired = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isUsed || isExpired ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Discount Badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUsed || isExpired
                      ? Colors.grey[200]
                      : AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    coupon.discount,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUsed || isExpired
                          ? Colors.grey
                          : AppTheme.successColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Coupon Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.storeName,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    if (isUsed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'USED',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'EXPIRED',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Expires ${_formatDate(coupon.endDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),

              // Actions
              if (!isUsed && !isExpired)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleCouponAction(coupon, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'use', child: Text('Mark as Used')),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuItem(value: 'remove', child: Text('Remove')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state widgets
  Widget _buildEmptyShoppingLists() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Shopping Lists Yet',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first shopping list to get organized',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewShoppingList(),
            icon: const Icon(Icons.add),
            label: const Text('Create Your First List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your Wishlist is Empty',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items you want and get notified when prices drop',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addToWishlist(),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: AppTheme.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySavedFlyers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Saved Flyers',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse flyers and save the ones you like',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySavedCoupons() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Saved Coupons',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse coupons and save the ones you want to use',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0) {
      return 'In ${difference.inDays} days';
    } else {
      final pastDays = difference.inDays.abs();
      if (pastDays == 1) {
        return 'Yesterday';
      } else if (pastDays < 7) {
        return '$pastDays days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  // Action methods
  void _createNewShoppingList() async {
    if (userEmail == null) return;

    final service = ref.read(savedItemsServiceProvider);
    final success = await service.createShoppingList(
      title: 'New Shopping List',
      userEmail: userEmail!,
    );

    if (success) {
      ref.refresh(shoppingListsProvider(userEmail!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shopping list created successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create shopping list')),
        );
      }
    }
  }

  void _openShoppingList(ShoppingList list) {
    // Navigate to shopping list detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening shopping list: ${list.title}')),
    );
  }

  void _handleListAction(ShoppingList list, String action) {
    switch (action) {
      case 'edit':
        // Navigate to edit page
        break;
      case 'share':
        // Share functionality
        break;
      case 'delete':
        // Delete with confirmation
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action shopping list: ${list.title}')),
    );
  }

  void _addToWishlist() {
    // Navigate to add wishlist item page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add to wishlist feature coming soon!')),
    );
  }

  void _handleWishlistAction(WishlistItem item, String action) {
    switch (action) {
      case 'edit':
        // Navigate to edit page
        break;
      case 'share':
        // Share functionality
        break;
      case 'remove':
        // Remove with confirmation
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action wishlist item: ${item.name}')),
    );
  }

  void _removeSavedFlyer(SavedFlyer flyer) {
    // Implement remove functionality
    ref.refresh(savedFlyersProvider(userEmail!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${flyer.title} from saved flyers')),
    );
  }

  void _handleCouponAction(SavedCoupon coupon, String action) {
    switch (action) {
      case 'use':
        // Mark as used functionality
        ref.refresh(savedCouponsProvider(userEmail!));
        break;
      case 'share':
        // Share functionality
        break;
      case 'remove':
        // Remove functionality
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action coupon: ${coupon.title}')),
    );
  }
}

// Required provider references (adjust these to match your actual providers)
// These should be imported from your existing files:
final dioProvider = Provider<Dio>((ref) => throw UnimplementedError());
final topPrixAuthProvider =
    StateNotifierProvider<TopPrixAuthNotifier, TopPrixAuthState>(
        (ref) => throw UnimplementedError());

// Placeholder classes - replace these with your actual auth classes
class TopPrixAuthState {
  final BackendUser? backendUser;

  TopPrixAuthState({this.backendUser});
}

class BackendUser {
  final String? email;

  BackendUser({this.email});
}

class TopPrixAuthNotifier extends StateNotifier<TopPrixAuthState> {
  TopPrixAuthNotifier() : super(TopPrixAuthState());
}
