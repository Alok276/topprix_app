import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shopping List Models
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
}

// Wishlist Models
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

  bool get isPriceDropped {
    if (targetPrice == null || currentPrice == null) return false;
    return currentPrice! <= targetPrice!;
  }
}

// Saved Items Models
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
}

class SavedTab extends ConsumerStatefulWidget {
  const SavedTab({super.key});

  @override
  ConsumerState<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends ConsumerState<SavedTab>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - replace with actual backend calls
  final List<ShoppingList> _shoppingLists = [
    ShoppingList(
      id: '1',
      userId: 'user1',
      title: 'Weekly Groceries',
      items: [
        ShoppingListItem(id: '1', name: 'Milk', quantity: 2),
        ShoppingListItem(
            id: '2', name: 'Bread', quantity: 1, isCompleted: true),
        ShoppingListItem(id: '3', name: 'Eggs', quantity: 12),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    ShoppingList(
      id: '2',
      userId: 'user1',
      title: 'Electronics Shopping',
      items: [
        ShoppingListItem(id: '4', name: 'Laptop', quantity: 1),
        ShoppingListItem(
            id: '5', name: 'Mouse', quantity: 1, isCompleted: true),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<WishlistItem> _wishlistItems = [
    WishlistItem(
      id: '1',
      name: 'iPhone 15 Pro Max with Extended Warranty and Premium Case',
      targetPrice: 999.0,
      currentPrice: 1099.0,
      storeName: 'Best Buy Electronics Store',
      imageUrl: 'https://via.placeholder.com/80x80',
    ),
    WishlistItem(
      id: '2',
      name: 'Nike Air Max 270 React Premium Running Shoes',
      targetPrice: 120.0,
      currentPrice: 89.99,
      storeName: 'Nike Official Store',
      imageUrl: 'https://via.placeholder.com/80x80',
      isPriceAlert: true,
    ),
    WishlistItem(
      id: '3',
      name: 'MacBook Pro 16-inch with M3 Chip',
      targetPrice: 2200.0,
      currentPrice: 2499.0,
      storeName: 'Apple Store',
      imageUrl: 'https://via.placeholder.com/80x80',
    ),
  ];

  final List<SavedFlyer> _savedFlyers = [
    SavedFlyer(
      id: '1',
      title: 'Electronics Sale',
      storeName: 'Best Buy',
      imageUrl: 'https://via.placeholder.com/200x150',
      endDate: DateTime.now().add(const Duration(days: 5)),
      isExpired: false,
    ),
    SavedFlyer(
      id: '2',
      title: 'Fashion Week',
      storeName: 'Target',
      imageUrl: 'https://via.placeholder.com/200x150',
      endDate: DateTime.now().subtract(const Duration(days: 1)),
      isExpired: true,
    ),
  ];

  final List<SavedCoupon> _savedCoupons = [
    SavedCoupon(
      id: '1',
      title: '20% Off Your Purchase',
      storeName: 'Target',
      discount: '20% OFF',
      endDate: DateTime.now().add(const Duration(days: 2)),
      isExpired: false,
    ),
    SavedCoupon(
      id: '2',
      title: 'Free Shipping',
      storeName: 'Amazon',
      discount: 'FREE SHIPPING',
      endDate: DateTime.now().add(const Duration(days: 10)),
      isExpired: false,
      isUsed: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: const Color(0xFF6366F1),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart, size: 16),
                    const SizedBox(width: 4),
                    Text('Lists (${_shoppingLists.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, size: 16),
                    const SizedBox(width: 4),
                    Text('Wishlist (${_wishlistItems.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_offer, size: 16),
                    const SizedBox(width: 4),
                    Text('Flyers (${_savedFlyers.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number, size: 16),
                    const SizedBox(width: 4),
                    Text('Coupons (${_savedCoupons.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildShoppingListsView(),
              _buildWishlistView(),
              _buildSavedFlyersView(),
              _buildSavedCouponsView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingListsView() {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh shopping lists from backend
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
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_shoppingLists.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyShoppingLists(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final list = _shoppingLists[index];
                  return _buildShoppingListCard(list);
                },
                childCount: _shoppingLists.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShoppingListCard(ShoppingList list) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: list.progress,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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

  Widget _buildEmptyShoppingLists() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Shopping Lists Yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistView() {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh wishlist from backend
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
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_wishlistItems.isEmpty)
            SliverFillRemaining(child: _buildEmptyWishlist())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _wishlistItems[index];
                  return _buildWishlistItemCard(item);
                },
                childCount: _wishlistItems.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWishlistItemCard(WishlistItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: item.isPriceDropped
            ? Border.all(color: Colors.green, width: 2)
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
              // Product Image - Fixed size
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

              // Product Info - Flexible width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name - With proper text wrapping
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Store Name
                    if (item.storeName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.storeName!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Price Information - Wrapped in flexible layout
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
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '\$${item.currentPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: item.isPriceDropped
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),
                          ),
                        if (item.targetPrice != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Target: \$${item.targetPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Price Drop Alert
                    if (item.isPriceDropped) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_down,
                              size: 14,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Price Drop Alert! 🎉',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
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

              // Actions - Fixed width
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
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedFlyersView() {
    final activeFlyers = _savedFlyers.where((f) => !f.isExpired).toList();
    final expiredFlyers = _savedFlyers.where((f) => f.isExpired).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh saved flyers from backend
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Saved Flyers (${_savedFlyers.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Active Flyers
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

          // Expired Flyers
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
                    color: Colors.grey[600],
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

          if (_savedFlyers.isEmpty)
            SliverFillRemaining(child: _buildEmptySavedFlyers()),
        ],
      ),
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
              child: const Center(
                child: Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),

            // Overlay
            if (isExpired)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    'EXPIRED',
                    style: TextStyle(
                      color: Colors.white,
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
                        color: Colors.white,
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
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isExpired
                          ? 'Expired'
                          : 'Ends ${_formatDate(flyer.endDate)}',
                      style: const TextStyle(
                        color: Colors.white70,
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
                    color: Colors.white,
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

  Widget _buildEmptySavedFlyers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Saved Flyers',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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

  Widget _buildSavedCouponsView() {
    final activeCoupons =
        _savedCoupons.where((c) => !c.isExpired && !c.isUsed).toList();
    final usedCoupons = _savedCoupons.where((c) => c.isUsed).toList();
    final expiredCoupons = _savedCoupons.where((c) => c.isExpired).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh saved coupons from backend
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Saved Coupons (${_savedCoupons.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Active Coupons
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

          // Used Coupons
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
                    color: Colors.grey[600],
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

          if (_savedCoupons.isEmpty)
            SliverFillRemaining(child: _buildEmptySavedCoupons()),
        ],
      ),
    );
  }

  Widget _buildCouponCard(SavedCoupon coupon,
      {bool isUsed = false, bool isExpired = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    coupon.discount,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUsed || isExpired ? Colors.grey : Colors.green,
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
                      style: TextStyle(color: Colors.grey[600]),
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
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'EXPIRED',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[700],
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
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Action methods
  void _createNewShoppingList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Create shopping list feature coming soon!')),
    );
  }

  void _openShoppingList(ShoppingList list) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening shopping list: ${list.title}')),
    );
  }

  void _handleListAction(ShoppingList list, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action shopping list: ${list.title}')),
    );
  }

  void _addToWishlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add to wishlist feature coming soon!')),
    );
  }

  void _handleWishlistAction(WishlistItem item, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action wishlist item: ${item.name}')),
    );
  }

  void _removeSavedFlyer(SavedFlyer flyer) {
    setState(() {
      _savedFlyers.remove(flyer);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${flyer.title} from saved flyers')),
    );
  }

  void _handleCouponAction(SavedCoupon coupon, String action) {
    if (action == 'use') {
      setState(() {
        final index = _savedCoupons.indexOf(coupon);
        _savedCoupons[index] = SavedCoupon(
          id: coupon.id,
          title: coupon.title,
          storeName: coupon.storeName,
          discount: coupon.discount,
          endDate: coupon.endDate,
          isExpired: coupon.isExpired,
          isUsed: true,
        );
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action coupon: ${coupon.title}')),
    );
  }
}
