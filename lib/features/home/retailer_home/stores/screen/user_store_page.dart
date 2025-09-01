import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/auth/service/backend_user_service.dart';
import 'package:topprix/features/home/retailer_home/stores/models/store.dart';
import 'package:topprix/features/home/retailer_home/stores/screen/store_detail_page.dart';
import 'package:topprix/features/home/retailer_home/stores/services/store_service.dart';
// Import your API service and model classes
// import 'your_api_service.dart';
// import 'get_store_model.dart';

class UserStoresPage extends StatefulWidget {
  const UserStoresPage({
    super.key,
  });

  @override
  State<UserStoresPage> createState() => _UserStoresPageState();
}

class _UserStoresPageState extends State<UserStoresPage> {
  List<Store> stores = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserStores();
  }

  Future<void> _loadUserStores() async {
    try {
      // Replace with your actual API service instance
      CreateStoreService storeService = CreateStoreService();

      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final userEmail = await TopPrixAuthService().getCurrentUserEmail();
      if (userEmail.isEmpty) {
        throw Exception('User email not found. Please log in again.');
      }

      final storeResponse = await storeService.getUserStores(userEmail);
      final BackendUserService backendUserService = BackendUserService();
      final response =
          await backendUserService.getCurrentUserProfile(email: userEmail);
      final BackendUser currentUser = response.data!;
      final userId = currentUser.id;
      if (userId == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // For demo purposes, using mock data
      // You should replace this with actual API call:
      final filteredStores = storeResponse
          .stores // ✅ CORRECT: Access the stores list from the model
          .where((store) => store.ownerId == userId)
          .toList();

      setState(() {
        stores = filteredStores; // Use filtered stores by owner ID
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load stores: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Stores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserStores,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create new store page
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Store',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildErrorWidget();
    }

    if (stores.isEmpty) {
      return _buildEmptyStateWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadUserStores,
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                0.85, // Adjusted to work with the more compact design
          ),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            return _buildStoreCard(stores[index]);
          },
        ),
      ),
    );
  }

  Widget _buildStoreCard(Store store) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to store details page
          _navigateToStoreDetails(store);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Logo Section
            Container(
              height: 100, // Reduced from 120
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
              child: store.logo != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: store.logo!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildDefaultLogo(),
                      ),
                    )
                  : _buildDefaultLogo(),
            ),

            // Store Information Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8), // Reduced from 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Store Name
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 14, // Reduced from 16
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4

                    // Store Address
                    Text(
                      store.address,
                      style: TextStyle(
                        fontSize: 11, // Reduced from 12
                        color: Colors.grey[600],
                      ),
                      maxLines: 1, // Reduced from 2
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Reduced from 8

                    // Categories - Only show one if present
                    if (store.categories.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          store.categories.first.name,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Store Stats - Simplified
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatChip(
                            Icons.local_offer,
                            '${store.count.flyers}',
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildStatChip(
                            Icons.card_giftcard,
                            '${store.count.coupons}',
                            Colors.green,
                          ),
                        ),
                      ],
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

  Widget _buildDefaultLogo() {
    return const Center(
      child: Icon(
        Icons.store,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 8,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Stores Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t created any stores yet.\nTap the + button to create your first store!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create store page
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Store'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserStores,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStoreDetails(Store store) {
    // Implement navigation to store details page
    print('Navigate to store: ${store.name}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailPage(store: store),
      ),
    );
  }
}
