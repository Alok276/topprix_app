import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/auth/service/backend_user_service.dart';
import 'package:topprix/features/home/user_home/tabs/coupons.dart';
import 'package:topprix/features/home/user_home/tabs/flyer.dart';
import 'package:topprix/features/home/user_home/tabs/stores.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

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
    final user = ref.watch(currentBackendUserProvider);

    return Scaffold(
      appBar: _buildAppBar(user),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ============================================================================
  // 3. APP BAR WITH USER INFO & NOTIFICATIONS
  // ============================================================================

  PreferredSizeWidget _buildAppBar(BackendUser? user) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome ${user?.name?.split(' ').first ?? 'User'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (user?.location != null)
            Text(
              user!.location!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.pushNamed(context, '/search'),
        ),
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        // Profile
        IconButton(
          icon: const Icon(Icons.person_outline),
          // icon: CircleAvatar(
          //   radius: 16,
          //   backgroundImage: user?.profilePicture != null
          //       ? NetworkImage(user!.profilePicture!)
          //       : null,
          //   child: user?.profilePicture == null
          //       ? Text(
          //           user?.name?.substring(0, 1).toUpperCase() ?? 'U',
          //           style: const TextStyle(fontSize: 14),
          //         )
          //       : null,
          // ),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  // ============================================================================
  // 4. MAIN BODY WITH TAB CONTROLLER
  // ============================================================================

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: const [
        HomeTab(), // Featured flyers, nearby deals
        FlyersTab(), // All flyers with filters
        CouponsTab(), // All coupons with save functionality
        StoresTab(), // Store listings
        //SavedTab(),          // Saved items, shopping lists, wishlist
      ],
    );
  }

  // ============================================================================
  // 5. BOTTOM NAVIGATION
  // ============================================================================

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF6366F1),
      unselectedItemColor: Colors.grey[600],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          _tabController.animateTo(index);
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          activeIcon: Icon(Icons.local_offer),
          label: 'Flyers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined),
          activeIcon: Icon(Icons.confirmation_number),
          label: 'Coupons',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Stores',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.bookmark_outline),
        //   activeIcon: Icon(Icons.bookmark),
        //   label: 'Saved',
        // ),
      ],
    );
  }

  // ============================================================================
  // 6. FLOATING ACTION BUTTON - SHOPPING LIST
  // ============================================================================

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showShoppingListOptions(),
      backgroundColor: const Color(0xFF6366F1),
      child: const Icon(Icons.add_shopping_cart),
    );
  }

  void _showShoppingListOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create New Shopping List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shopping-list/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('View Shopping Lists'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shopping-lists');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('View Wishlist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/wishlist');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. HOME TAB - FEATURED CONTENT
// ============================================================================

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          _buildQuickActions(context),
          const SizedBox(height: 24),

          // Nearby deals section
          _buildSectionHeader('Nearby Deals', () {
            Navigator.pushNamed(context, '/nearby-deals');
          }),
          const SizedBox(height: 12),
          _buildNearbyDealsCarousel(),
          const SizedBox(height: 24),

          // Featured flyers
          _buildSectionHeader('Featured Flyers', () {
            Navigator.pushNamed(context, '/flyers');
          }),
          const SizedBox(height: 12),
          _buildFeaturedFlyersGrid(),
          const SizedBox(height: 24),

          // Categories
          _buildSectionHeader('Shop by Category', () {
            Navigator.pushNamed(context, '/categories');
          }),
          const SizedBox(height: 12),
          _buildCategoriesGrid(),
          const SizedBox(height: 24),

          // Preferred stores
          _buildSectionHeader('Your Favorite Stores', () {
            Navigator.pushNamed(context, '/preferred-stores');
          }),
          const SizedBox(height: 12),
          _buildPreferredStoresCarousel(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: Icons.qr_code_scanner,
            label: 'Scan Coupon',
            onTap: () => Navigator.pushNamed(context, '/scan-coupon'),
          ),
          _buildQuickActionItem(
            icon: Icons.location_on,
            label: 'Find Stores',
            onTap: () => Navigator.pushNamed(context, '/find-stores'),
          ),
          _buildQuickActionItem(
            icon: Icons.local_offer,
            label: 'Best Deals',
            onTap: () => Navigator.pushNamed(context, '/best-deals'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildNearbyDealsCarousel() {
    // TODO: Implement with real data from API
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/images/test.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Special Offer Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        '0.5 km away',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedFlyersGrid() {
    // TODO: Implement with real data from API
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/test.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Valid until Dec 31',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {'name': 'Groceries', 'icon': Icons.shopping_cart, 'color': Colors.green},
      {
        'name': 'Electronics',
        'icon': Icons.phone_android,
        'color': Colors.blue
      },
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Home & Garden', 'icon': Icons.home, 'color': Colors.orange},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, '/category/${category['name']}'),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['name'] as String,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreferredStoresCarousel() {
    // TODO: Implement with real data from API
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/test.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Store',
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
