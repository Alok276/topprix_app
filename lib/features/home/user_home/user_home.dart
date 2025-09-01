import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/home/user_home/home_dashboard_tab.dart';
import 'package:topprix/features/home/user_home/search_page.dart';
import 'package:topprix/features/home/user_home/tabs/antiwaste.dart';
import 'package:topprix/features/home/user_home/tabs/coupons.dart';
import 'package:topprix/features/home/user_home/tabs/flyer.dart';
import 'package:topprix/features/home/user_home/tabs/notifications_page.dart';
import 'package:topprix/features/home/user_home/tabs/saved.dart';
import 'package:topprix/features/home/user_home/profile_page.dart';
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
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
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
      floatingActionButton:
          _currentIndex == 0 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic user) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      title: _buildAppBarTitle(user),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _navigateToSearch(),
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
          onPressed: () => _navigateToNotifications(),
        ),
        // Profile button (moved from tab to app bar)
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user?.name?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () => _navigateToProfile(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarTitle(dynamic user) {
    switch (_currentIndex) {
      case 0:
        return Column(
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
        );
      case 1:
        return const Text('Flyers');
      case 2:
        return const Text('Coupons');
      case 3:
        return const Text('Stores');
      case 4:
        return const Text('AntiWaste');
      default:
        return const Text('TopPrix');
    }
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(), // Disable swipe
      children: const [
        HomeDashboardTab(), // Enhanced dashboard
        FlyersTab(), // Your existing flyers tab
        CouponsTab(), // Your existing coupons tab
        StoresTab(), // Your existing stores tab
        AntiWasteTabBar() // New saved items tab
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon:
                _buildNavIcon(Icons.local_offer_outlined, Icons.local_offer, 1),
            label: 'Flyers',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.confirmation_number_outlined,
                Icons.confirmation_number, 2),
            label: 'Coupons',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.store_outlined, Icons.store, 3),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.recycling_outlined, Icons.recycling, 4),
            label: 'AntiWaste',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    final isSelected = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6366F1).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isSelected ? filledIcon : outlinedIcon,
        size: 24,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showQuickActions(),
      backgroundColor: const Color(0xFF6366F1),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_shopping_cart, color: Colors.green),
              ),
              title: const Text('Create Shopping List'),
              subtitle: const Text('Plan your shopping trip'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateShoppingList();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite_border, color: Colors.orange),
              ),
              title: const Text('Add to Wishlist'),
              subtitle: const Text('Save items for later'),
              onTap: () {
                Navigator.pop(context);
                _navigateToWishlist();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              ),
              title: const Text('Scan QR Code'),
              subtitle: const Text('Scan coupon or flyer'),
              onTap: () {
                Navigator.pop(context);
                _navigateToQRScanner();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on, color: Colors.purple),
              ),
              title: const Text('Find Nearby Deals'),
              subtitle: const Text('Discover local offers'),
              onTap: () {
                Navigator.pop(context);
                _navigateToNearbyDeals();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  void _navigateToProfile() {
    // Navigate to profile page (can be separate page or modal)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
    // Navigator.pushNamed(context, '/profile');
  }

  void _navigateToCreateShoppingList() {
    // Will navigate to shopping list creation in SavedTab
    setState(() {
      _currentIndex = 4;
      _tabController.animateTo(4);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Navigated to Saved tab for shopping lists')),
    );
  }

  void _navigateToWishlist() {
    // Will navigate to wishlist in SavedTab
    setState(() {
      _currentIndex = 4;
      _tabController.animateTo(4);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigated to Saved tab for wishlist')),
    );
  }

  void _navigateToQRScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scanner feature coming soon!')),
    );
  }

  void _navigateToNearbyDeals() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nearby Deals feature coming soon!')),
    );
  }
}
