import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/provider/dio_provider.dart';

// Flyer Model (matches your API)
class Flyer {
  final String id;
  final String title;
  final String storeId;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isSponsored;
  final bool isPremium;
  final double? price;
  final bool isPaid;
  final Store? store;
  final List<Category> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flyer({
    required this.id,
    required this.title,
    required this.storeId,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.isSponsored = false,
    this.isPremium = false,
    this.price,
    this.isPaid = false,
    this.store,
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flyer.fromJson(Map<String, dynamic> json) {
    return Flyer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      storeId: json['storeId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isSponsored: json['isSponsored'] ?? false,
      isPremium: json['isPremium'] ?? false,
      price: json['price']?.toDouble(),
      isPaid: json['isPaid'] ?? false,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((e) => Category.fromJson(e))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Store Model
class Store {
  final String id;
  final String name;
  final String? logo;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;

  Store({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

// Category Model
class Category {
  final String id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

// Flyers Service
class FlyersService {
  final Dio _dio;

  FlyersService(this._dio);

  Future<List<Flyer>> getFlyers({
    String? storeId,
    String? categoryId,
    bool? isSponsored,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storeId != null) queryParams['storeId'] = storeId;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isSponsored != null) queryParams['isSponsored'] = isSponsored;

      final response = await _dio.get('/flyers', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> flyersJson =
            response.data['flyers'] ?? response.data;
        return flyersJson.map((json) => Flyer.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching flyers: $e');
      return [];
    }
  }

  Future<Flyer?> getFlyerById(String id) async {
    try {
      final response = await _dio.get('/flyers/$id');

      if (response.statusCode == 200) {
        return Flyer.fromJson(response.data['flyer'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching flyer: $e');
      return null;
    }
  }

  Future<bool> saveFlyer(String flyerId, String userEmail) async {
    try {
      final response = await _dio.post(
        '/flyers/save',
        data: {'flyerId': flyerId},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error saving flyer: $e');
      return false;
    }
  }
}

// Providers
final flyersServiceProvider = Provider<FlyersService>((ref) {
  final dio = ref.read(dioProvider); // You'll need to create this
  return FlyersService(dio);
});

final flyersProvider =
    FutureProvider.family<List<Flyer>, FlyerFilters>((ref, filters) async {
  final service = ref.read(flyersServiceProvider);
  return service.getFlyers(
    storeId: filters.storeId,
    categoryId: filters.categoryId,
    isSponsored: filters.isSponsored,
  );
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  // TODO: Implement categories API call
  return [];
});

final storesProvider = FutureProvider<List<Store>>((ref) async {
  // TODO: Implement stores API call
  return [];
});

// Filter State
class FlyerFilters {
  final String? storeId;
  final String? categoryId;
  final bool? isSponsored;
  final String? searchQuery;

  FlyerFilters({
    this.storeId,
    this.categoryId,
    this.isSponsored,
    this.searchQuery,
  });

  FlyerFilters copyWith({
    String? storeId,
    String? categoryId,
    bool? isSponsored,
    String? searchQuery,
  }) {
    return FlyerFilters(
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      isSponsored: isSponsored ?? this.isSponsored,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final flyerFiltersProvider =
    StateProvider<FlyerFilters>((ref) => FlyerFilters());

// FlyersTab Widget
class FlyersTab extends ConsumerStatefulWidget {
  const FlyersTab({super.key});

  @override
  ConsumerState<FlyersTab> createState() => _FlyersTabState();
}

class _FlyersTabState extends ConsumerState<FlyersTab> {
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
    final filters = ref.watch(flyerFiltersProvider);
    final flyersAsync = ref.watch(flyersProvider(filters));

    return Column(
      children: [
        // Search and Filter Header
        _buildSearchAndFilterHeader(),

        // Active Filters Chips
        _buildActiveFiltersChips(),

        // Flyers Content
        Expanded(
          child: flyersAsync.when(
            data: (flyers) => _buildFlyersContent(flyers),
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
                hintText: 'Search flyers...',
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
                ref.read(flyerFiltersProvider.notifier).update(
                      (state) => state.copyWith(searchQuery: value),
                    );
              },
            ),
          ),
          const SizedBox(width: 12),

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

  Widget _buildActiveFiltersChips() {
    final filters = ref.watch(flyerFiltersProvider);
    final hasActiveFilters = filters.storeId != null ||
        filters.categoryId != null ||
        filters.isSponsored != null;

    if (!hasActiveFilters) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (filters.storeId != null)
            _buildFilterChip(
              label: 'Store Filter',
              onRemove: () => _removeFilter('store'),
            ),
          if (filters.categoryId != null)
            _buildFilterChip(
              label: 'Category Filter',
              onRemove: () => _removeFilter('category'),
            ),
          if (filters.isSponsored != null)
            _buildFilterChip(
              label: 'Sponsored Only',
              onRemove: () => _removeFilter('sponsored'),
            ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
        deleteIconColor: const Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildFlyersContent(List<Flyer> flyers) {
    if (flyers.isEmpty) {
      return _buildEmptyState();
    }

    // Separate sponsored and regular flyers
    final sponsoredFlyers = flyers.where((f) => f.isSponsored).toList();
    final regularFlyers = flyers.where((f) => !f.isSponsored).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(flyersProvider);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sponsored Flyers Section
          if (sponsoredFlyers.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Sponsored Deals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sponsoredFlyers.length,
                  itemBuilder: (context, index) {
                    return _buildSponsoredFlyerCard(sponsoredFlyers[index]);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // Regular Flyers Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'All Flyers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildFlyerCard(regularFlyers[index]),
                childCount: regularFlyers.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSponsoredFlyerCard(Flyer flyer) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Flyer Image
            Image.network(
              flyer.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                );
              },
            ),

            // Sponsored Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'SPONSORED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Positioned(
              top: 12,
              right: 12,
              child: _buildSaveButton(flyer),
            ),

            // Bottom Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (flyer.store != null)
                      Text(
                        flyer.store!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Valid until ${_formatDate(flyer.endDate)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
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
  }

  Widget _buildFlyerCard(Flyer flyer) {
    return GestureDetector(
      onTap: () => _openFlyerDetails(flyer),
      child: Container(
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
              Image.network(
                flyer.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.image, size: 40, color: Colors.grey),
                  );
                },
              ),

              // Premium Badge
              if (flyer.isPremium)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Save Button
              Positioned(
                top: 8,
                right: 8,
                child: _buildSaveButton(flyer),
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
                        Colors.black.withOpacity(0.7),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (flyer.store != null)
                        Text(
                          flyer.store!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        'Valid until ${_formatDate(flyer.endDate)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(Flyer flyer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
        onPressed: () => _saveFlyer(flyer),
      ),
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
            'Failed to load flyers',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(flyersProvider),
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
          const Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No flyers found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
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
      builder: (context) => const FlyerFiltersBottomSheet(),
    );
  }

  void _removeFilter(String filterType) {
    final notifier = ref.read(flyerFiltersProvider.notifier);
    switch (filterType) {
      case 'store':
        notifier.update((state) => state.copyWith(storeId: null));
        break;
      case 'category':
        notifier.update((state) => state.copyWith(categoryId: null));
        break;
      case 'sponsored':
        notifier.update((state) => state.copyWith(isSponsored: null));
        break;
    }
  }

  void _clearAllFilters() {
    ref.read(flyerFiltersProvider.notifier).state = FlyerFilters();
  }

  Future<void> _saveFlyer(Flyer flyer) async {
    final user = ref.read(currentBackendUserProvider);
    if (user == null) return;

    final service = ref.read(flyersServiceProvider);
    final success = await service.saveFlyer(flyer.id, user.email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flyer saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openFlyerDetails(Flyer flyer) {
    Navigator.pushNamed(context, '/flyer-details', arguments: flyer.id);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Filter Bottom Sheet
class FlyerFiltersBottomSheet extends ConsumerWidget {
  const FlyerFiltersBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(flyerFiltersProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Flyers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Store Filter
          const Text('Store', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // TODO: Implement store dropdown

          const SizedBox(height: 20),

          // Category Filter
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // TODO: Implement category dropdown

          const SizedBox(height: 20),

          // Sponsored Filter
          CheckboxListTile(
            title: const Text('Sponsored Only'),
            value: filters.isSponsored ?? false,
            onChanged: (value) {
              ref.read(flyerFiltersProvider.notifier).update(
                    (state) => state.copyWith(isSponsored: value),
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
