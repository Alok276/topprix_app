import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/auth/service/backend_user_service.dart';
import 'package:topprix/features/home/user_home/tabs/flyer.dart';
import 'package:topprix/provider/dio_provider.dart';

// Extended Store Model (matches your API)
class StoreDetailed {
  final String id;
  final String name;
  final String? logo;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? ownerId;
  final List<Category> categories;
  final BackendUser? owner;
  final int flyersCount;
  final int couponsCount;
  final bool isPreferred;
  final double? distance; // in km
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreDetailed({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.ownerId,
    this.categories = const [],
    this.owner,
    this.flyersCount = 0,
    this.couponsCount = 0,
    this.isPreferred = false,
    this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreDetailed.fromJson(Map<String, dynamic> json) {
    return StoreDetailed(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      ownerId: json['ownerId'],
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((e) => Category.fromJson(e))
              .toList()
          : [],
      owner: json['owner'] != null ? BackendUser.fromJson(json['owner']) : null,
      flyersCount: json['flyersCount'] ?? 0,
      couponsCount: json['couponsCount'] ?? 0,
      isPreferred: json['isPreferred'] ?? false,
      distance: json['distance']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Stores Service
class StoresService {
  final Dio _dio;

  StoresService(this._dio);

  Future<List<StoreDetailed>> getStores({
    String? categoryId,
    String? name,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category'] = categoryId;
      if (name != null) queryParams['name'] = name;
      if (location != null) queryParams['location'] = location;

      final response = await _dio.get('/stores', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> storesJson =
            response.data['stores'] ?? response.data;
        return storesJson.map((json) => StoreDetailed.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching stores: $e');
      return [];
    }
  }

  Future<StoreDetailed?> getStoreById(String id) async {
    try {
      final response = await _dio.get('/store/$id');

      if (response.statusCode == 200) {
        return StoreDetailed.fromJson(response.data['store'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching store: $e');
      return null;
    }
  }

  Future<List<StoreDetailed>> getNearbyStores({
    required double latitude,
    required double longitude,
    int radius = 10, // km
  }) async {
    try {
      final response = await _dio.get(
        '/location/nearby-stores',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesJson =
            response.data['stores'] ?? response.data;
        return storesJson.map((json) => StoreDetailed.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching nearby stores: $e');
      return [];
    }
  }

  Future<bool> addPreferredStore(String storeId, String userEmail) async {
    try {
      final response = await _dio.post(
        '/user/$userEmail/preferred-stores/add',
        data: {'storeId': storeId},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding preferred store: $e');
      return false;
    }
  }

  Future<bool> removePreferredStore(String storeId, String userEmail) async {
    try {
      final response = await _dio.post(
        '/user/$userEmail/preferred-stores/remove',
        data: {'storeId': storeId},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing preferred store: $e');
      return false;
    }
  }

  Future<List<StoreDetailed>> getPreferredStores(String userEmail) async {
    try {
      final response = await _dio.get(
        '/user/$userEmail/preferred-stores',
        options: Options(headers: {'user-email': userEmail}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesJson =
            response.data['stores'] ?? response.data;
        return storesJson.map((json) => StoreDetailed.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching preferred stores: $e');
      return [];
    }
  }
}

// Filter State
class StoreFilters {
  final String? categoryId;
  final String? searchQuery;
  final String? location;
  final bool nearbyOnly;
  final bool preferredOnly;

  StoreFilters({
    this.categoryId,
    this.searchQuery,
    this.location,
    this.nearbyOnly = false,
    this.preferredOnly = false,
  });

  StoreFilters copyWith({
    String? categoryId,
    String? searchQuery,
    String? location,
    bool? nearbyOnly,
    bool? preferredOnly,
  }) {
    return StoreFilters(
      categoryId: categoryId ?? this.categoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      location: location ?? this.location,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
      preferredOnly: preferredOnly ?? this.preferredOnly,
    );
  }
}

// Providers
final storesServiceProvider = Provider<StoresService>((ref) {
  final dio = ref.read(dioProvider);
  return StoresService(dio);
});

final storeFiltersProvider =
    StateProvider<StoreFilters>((ref) => StoreFilters());

final storesProvider = FutureProvider.family<List<StoreDetailed>, StoreFilters>(
    (ref, filters) async {
  final service = ref.read(storesServiceProvider);

  if (filters.preferredOnly) {
    final user = ref.read(currentBackendUserProvider);
    if (user != null) {
      return service.getPreferredStores(user.email);
    }
    return [];
  }

  return service.getStores(
    categoryId: filters.categoryId,
    name: filters.searchQuery,
    location: filters.location,
  );
});

final preferredStoresProvider = StateProvider<Set<String>>((ref) => {});

// StoresTab Widget
class StoresTab extends ConsumerStatefulWidget {
  const StoresTab({super.key});

  @override
  ConsumerState<StoresTab> createState() => _StoresTabState();
}

class _StoresTabState extends ConsumerState<StoresTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(storeFiltersProvider);
    final storesAsync = ref.watch(storesProvider(filters));

    return Column(
      children: [
        // Search and Filter Header
        _buildSearchAndFilterHeader(),

        // Filter Chips
        _buildFilterChips(),

        // Stores Content
        Expanded(
          child: storesAsync.when(
            data: (stores) => _buildStoresContent(stores),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stores...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                ref.read(storeFiltersProvider.notifier).update(
                      (state) => state.copyWith(searchQuery: value),
                    );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Location Button
          Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onPressed: () => _findNearbyStores(),
            ),
          ),
          const SizedBox(width: 8),

          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () => _showFilterBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ref.watch(storeFiltersProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  label: 'Nearby',
                  isSelected: filters.nearbyOnly,
                  onTap: () => _toggleNearbyFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Favorites',
                  isSelected: filters.preferredOnly,
                  onTap: () => _togglePreferredFilter(),
                ),
                const SizedBox(width: 8),
                if (filters.categoryId != null)
                  _buildFilterChip(
                    label: 'Category',
                    isSelected: true,
                    onTap: () => _removeFilter('category'),
                  ),
                const SizedBox(width: 8),
                if (filters.categoryId != null ||
                    filters.nearbyOnly ||
                    filters.preferredOnly)
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStoresContent(List<StoreDetailed> stores) {
    if (stores.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(storesProvider);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          return _buildStoreCard(stores[index]);
        },
      ),
    );
  }

  Widget _buildStoreCard(StoreDetailed store) {
    final preferredStores = ref.watch(preferredStoresProvider);
    final isPreferred = preferredStores.contains(store.id) || store.isPreferred;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openStoreDetails(store),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Store Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: store.logo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              store.logo!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.store,
                                      color: Colors.grey, size: 30),
                            ),
                          )
                        : const Icon(Icons.store, color: Colors.grey, size: 30),
                  ),
                  const SizedBox(width: 16),

                  // Store Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (store.address != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  store.address!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (store.distance != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.directions_walk,
                                  size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                '${store.distance!.toStringAsFixed(1)} km away',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Favorite Button
                  IconButton(
                    icon: Icon(
                      isPreferred ? Icons.favorite : Icons.favorite_border,
                      color: isPreferred ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _togglePreferredStore(store),
                  ),
                ],
              ),

              // Description
              if (store.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  store.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.local_offer,
                    count: store.flyersCount,
                    label: 'Flyers',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    icon: Icons.confirmation_number,
                    count: store.couponsCount,
                    label: 'Coupons',
                    color: Colors.green,
                  ),
                  const Spacer(),

                  // View Store Button
                  TextButton(
                    onPressed: () => _openStoreDetails(store),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Store'),
                  ),
                ],
              ),

              // Categories
              if (store.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: store.categories.take(3).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
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
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Failed to load stores',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(storesProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No stores found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const StoreFiltersBottomSheet(),
    );
  }

  void _toggleNearbyFilter() {
    final notifier = ref.read(storeFiltersProvider.notifier);
    final current = ref.read(storeFiltersProvider).nearbyOnly;
    notifier.update((state) => state.copyWith(nearbyOnly: !current));
  }

  void _togglePreferredFilter() {
    final notifier = ref.read(storeFiltersProvider.notifier);
    final current = ref.read(storeFiltersProvider).preferredOnly;
    notifier.update((state) => state.copyWith(preferredOnly: !current));
  }

  void _removeFilter(String filterType) {
    final notifier = ref.read(storeFiltersProvider.notifier);
    switch (filterType) {
      case 'category':
        notifier.update((state) => state.copyWith(categoryId: null));
        break;
    }
  }

  void _clearAllFilters() {
    ref.read(storeFiltersProvider.notifier).state = StoreFilters();
  }

  Future<void> _findNearbyStores() async {
    // TODO: Implement location permission and GPS
    // For now, just toggle nearby filter
    _toggleNearbyFilter();
  }

  Future<void> _togglePreferredStore(StoreDetailed store) async {
    final user = ref.read(currentBackendUserProvider);
    if (user == null) return;

    final service = ref.read(storesServiceProvider);
    final preferredStores = ref.read(preferredStoresProvider.notifier);
    final isPreferred = ref.read(preferredStoresProvider).contains(store.id);

    bool success;
    if (isPreferred) {
      success = await service.removePreferredStore(store.id, user.email);
      if (success) {
        preferredStores.update((state) => state..remove(store.id));
      }
    } else {
      success = await service.addPreferredStore(store.id, user.email);
      if (success) {
        preferredStores.update((state) => state..add(store.id));
      }
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isPreferred ? 'Removed from favorites' : 'Added to favorites!'),
          backgroundColor: isPreferred ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  void _openStoreDetails(StoreDetailed store) {
    Navigator.pushNamed(context, '/store-details', arguments: store.id);
  }
}

// Store Filters Bottom Sheet
class StoreFiltersBottomSheet extends ConsumerWidget {
  const StoreFiltersBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(storeFiltersProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Stores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Category Filter
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // TODO: Implement category dropdown

          const SizedBox(height: 20),

          // Location Filters
          CheckboxListTile(
            title: const Text('Show nearby stores only'),
            value: filters.nearbyOnly,
            onChanged: (value) {
              ref.read(storeFiltersProvider.notifier).update(
                    (state) => state.copyWith(nearbyOnly: value ?? false),
                  );
            },
          ),

          CheckboxListTile(
            title: const Text('Show favorite stores only'),
            value: filters.preferredOnly,
            onChanged: (value) {
              ref.read(storeFiltersProvider.notifier).update(
                    (state) => state.copyWith(preferredOnly: value ?? false),
                  );
            },
          ),

          const SizedBox(height: 20),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
