import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/home/retailer_home/coupons/model/coupon.dart';
import 'package:topprix/features/home/retailer_home/coupons/screen/create_coupon_screen.dart';
import 'package:topprix/features/home/retailer_home/coupons/service/coupon_service.dart';
import 'package:topprix/features/home/retailer_home/flyer/screen/create_flyer_screen.dart';
import 'package:topprix/features/home/retailer_home/flyer/model/flyer_model.dart';
import 'package:topprix/features/home/retailer_home/flyer/services/flyer_service.dart';
import 'package:topprix/features/home/retailer_home/stores/models/store.dart';
import 'package:topprix/features/home/retailer_home/stores/screen/edit_store_page.dart';
import 'package:topprix/features/home/retailer_home/stores/services/store_service.dart';
// Import your models and services
// import 'store_model.dart';
// import 'flyer_models.dart';
// import 'coupon_models.dart';
// import 'flyer_service.dart';
// import 'coupon_service.dart';
// import 'create_store_service.dart';
// import 'auth_service.dart';

class StoreManagementPage extends StatefulWidget {
  final Store store;

  const StoreManagementPage({
    super.key,
    required this.store,
  });

  @override
  State<StoreManagementPage> createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Flyer> flyers = [];
  List<Coupon> coupons = [];
  bool isLoadingFlyers = true;
  bool isLoadingCoupons = true;
  String? flyerErrorMessage;
  String? couponErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStoreData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreData() async {
    await Future.wait([
      _loadStoreFlyers(),
      _loadStoreCoupons(),
    ]);
  }

  Future<void> _loadStoreFlyers() async {
    try {
      setState(() {
        isLoadingFlyers = true;
        flyerErrorMessage = null;
      });

      final userEmail = await TopPrixAuthService().getCurrentUserEmail();
      if (userEmail.isEmpty) {
        throw Exception('User email not found');
      }

      final flyerService = FlyerService();
      final storeFlyers = await flyerService.getStoreFlyersList(
        storeId: widget.store.id,
        userEmail: userEmail,
      );

      setState(() {
        flyers = storeFlyers;
        isLoadingFlyers = false;
      });
    } catch (e) {
      setState(() {
        flyerErrorMessage = 'Failed to load flyers: ${e.toString()}';
        isLoadingFlyers = false;
      });
    }
  }

  Future<void> _loadStoreCoupons() async {
    try {
      setState(() {
        isLoadingCoupons = true;
        couponErrorMessage = null;
      });

      final userEmail = await TopPrixAuthService().getCurrentUserEmail();
      if (userEmail.isEmpty) {
        throw Exception('User email not found');
      }

      final couponService = CouponService();
      final storeCoupons = await couponService.getCoupons(
        storeId: widget.store.id,
        userEmail: userEmail,
      );

      setState(() {
        coupons = storeCoupons;
        isLoadingCoupons = false;
      });
    } catch (e) {
      setState(() {
        couponErrorMessage = 'Failed to load coupons: ${e.toString()}';
        isLoadingCoupons = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.store.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _navigateToEditStore(),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteConfirmation(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStoreData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Store Header
          _buildStoreHeader(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.deepPurple,
              tabs: [
                Tab(
                  icon: const Icon(Icons.local_offer),
                  text: 'Flyers (${flyers.length})',
                ),
                Tab(
                  icon: const Icon(Icons.card_giftcard),
                  text: 'Coupons (${coupons.length})',
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFlyersTab(),
                _buildCouponsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _navigateToCreateFlyer(),
            backgroundColor: Colors.orange,
            heroTag: 'flyer',
            mini: true,
            child: const Icon(Icons.local_offer, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => _navigateToCreateCoupon(),
            backgroundColor: Colors.green,
            heroTag: 'coupon',
            mini: true,
            child: const Icon(Icons.card_giftcard, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Logo
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple, Colors.purpleAccent],
              ),
            ),
            child: widget.store.logo != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      widget.store.logo!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.store,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.store,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
          ),

          // Store Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.store.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                if (widget.store.description.isNotEmpty)
                  Text(
                    widget.store.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.store.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Store Stats
                Row(
                  children: [
                    _buildStatContainer(
                      Icons.local_offer,
                      '${flyers.length}',
                      'Flyers',
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatContainer(
                      Icons.card_giftcard,
                      '${coupons.length}',
                      'Coupons',
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Categories
                if (widget.store.categories.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.store.categories.take(3).map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatContainer(
      IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlyersTab() {
    if (isLoadingFlyers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    if (flyerErrorMessage != null) {
      return _buildErrorWidget(flyerErrorMessage!, _loadStoreFlyers);
    }

    if (flyers.isEmpty) {
      return _buildEmptyWidget(
        icon: Icons.photo_library_outlined,
        title: 'No Flyers Yet',
        subtitle:
            'Create your first flyer to start\npromoting deals and offers!',
        buttonText: 'Create Flyer',
        onPressed: _navigateToCreateFlyer,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStoreFlyers,
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: flyers.length,
          itemBuilder: (context, index) => _buildFlyerCard(flyers[index]),
        ),
      ),
    );
  }

  Widget _buildCouponsTab() {
    if (isLoadingCoupons) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    if (couponErrorMessage != null) {
      return _buildErrorWidget(couponErrorMessage!, _loadStoreCoupons);
    }

    if (coupons.isEmpty) {
      return _buildEmptyWidget(
        icon: Icons.card_giftcard_outlined,
        title: 'No Coupons Yet',
        subtitle: 'Create your first coupon to offer\ndiscounts to customers!',
        buttonText: 'Create Coupon',
        onPressed: _navigateToCreateCoupon,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStoreCoupons,
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: coupons.length,
          itemBuilder: (context, index) => _buildCouponCard(coupons[index]),
        ),
      ),
    );
  }

  Widget _buildFlyerCard(Flyer flyer) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showFlyerDetails(flyer),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                ),
              ),
              child: flyer.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        flyer.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child:
                              Icon(Icons.image, size: 30, color: Colors.white),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 30, color: Colors.white),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flyer.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Until ${_formatDate(flyer.endDate)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: flyer.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: flyer.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        flyer.isActive ? 'Active' : 'Expired',
                        style: TextStyle(
                          fontSize: 8,
                          color: flyer.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
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
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCouponDetails(coupon),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        coupon.discount,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (coupon.code != null && coupon.code!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          coupon.code!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Until ${_formatDate(coupon.endDate)}',
                      style: TextStyle(
                        fontSize: 9,
                        color: coupon.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: coupon.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            coupon.isActive ? 'Active' : 'Expired',
                            style: TextStyle(
                              fontSize: 7,
                              color:
                                  coupon.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          coupon.isOnline && coupon.isInStore
                              ? Icons.all_inclusive
                              : coupon.isOnline
                                  ? Icons.language
                                  : Icons.store,
                          size: 10,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToCreateFlyer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateFlyerPage(store: widget.store),
      ),
    ).then((result) {
      if (result == true) {
        _loadStoreFlyers();
      }
    });
  }

  void _navigateToCreateCoupon() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCouponPage(store: widget.store),
      ),
    ).then((result) {
      if (result == true) {
        _loadStoreCoupons();
      }
    });
  }

  void _navigateToEditStore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStorePage(store: widget.store),
      ),
    ).then((result) {
      if (result == true) {
        Navigator.pop(
            context, true); // Return to previous page with update flag
      }
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 28),
            const SizedBox(width: 8),
            const Text('Delete Store'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${widget.store.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Warning: This action cannot be undone',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deleting this store will also permanently delete:',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• All ${flyers.length} flyers',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                  Text(
                    '• All ${coupons.length} coupons',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                  Text(
                    '• All associated data',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Store'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStore() async {
    try {
      final userEmail = await TopPrixAuthService().getCurrentUserEmail();
      if (userEmail.isEmpty) {
        throw Exception('User email not found. Please log in again.');
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Deleting store...'),
            ],
          ),
        ),
      );

      final storeService = CreateStoreService();
      final deleteResponse = await storeService.deleteStore(
        storeId: widget.store.id,
        userEmail: userEmail,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (deleteResponse.flyerCount != null ||
          deleteResponse.couponCount != null) {
        // Store has related items (409 Conflict)
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Cannot Delete Store'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deleteResponse.message),
                  if (deleteResponse.flyerCount != null ||
                      deleteResponse.couponCount != null) ...[
                    const SizedBox(height: 12),
                    const Text('Related items:'),
                    if (deleteResponse.flyerCount != null)
                      Text('• ${deleteResponse.flyerCount} flyers'),
                    if (deleteResponse.couponCount != null)
                      Text('• ${deleteResponse.couponCount} coupons'),
                    const SizedBox(height: 8),
                    const Text(
                      'Please delete all flyers and coupons first, then try again.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // Store deleted successfully
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Store "${widget.store.name}" deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return to previous page
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Error'),
            content: Text('Failed to delete store: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showFlyerDetails(Flyer flyer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(flyer.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valid from: ${_formatDate(flyer.startDate)}'),
              Text('Valid until: ${_formatDate(flyer.endDate)}'),
              const SizedBox(height: 8),
              Text('Status: ${flyer.isActive ? "Active" : "Expired"}'),
              if (flyer.isSponsored) const Text('This is a sponsored flyer'),
              if (flyer.categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                    'Categories: ${flyer.categories.map((c) => c.name).join(', ')}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCouponDetails(Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(coupon.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coupon.code != null)
                Text('Code: ${coupon.code}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Discount: ${coupon.discount}'),
              const SizedBox(height: 8),
              if (coupon.description != null)
                Text('Description: ${coupon.description}'),
              const SizedBox(height: 8),
              Text('Valid from: ${_formatDate(coupon.startDate)}'),
              Text('Valid until: ${_formatDate(coupon.endDate)}'),
              const SizedBox(height: 8),
              Text('Status: ${coupon.isActive ? "Active" : "Expired"}'),
              Text('Available: ${coupon.availabilityText}'),
              if (coupon.categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                    'Categories: ${coupon.categories.map((c) => c.name).join(', ')}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
