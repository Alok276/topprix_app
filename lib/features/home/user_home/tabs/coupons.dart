import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/home/user_home/tabs/flyer.dart';
import 'package:topprix/provider/dio_provider.dart';

// Coupon Model (matches your API)
class Coupon {
  final String id;
  final String title;
  final String storeId;
  final String? code;
  final String? barcodeUrl;
  final String? qrCodeUrl;
  final String discount;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isOnline;
  final bool isInStore;
  final bool isPremium;
  final double? price;
  final Store? store;
  final List<Category> categories;
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Coupon({
    required this.id,
    required this.title,
    required this.storeId,
    this.code,
    this.barcodeUrl,
    this.qrCodeUrl,
    required this.discount,
    this.description,
    required this.startDate,
    required this.endDate,
    this.isOnline = true,
    this.isInStore = true,
    this.isPremium = false,
    this.price,
    this.store,
    this.categories = const [],
    this.isSaved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      storeId: json['storeId'] ?? '',
      code: json['code'],
      barcodeUrl: json['barcodeUrl'],
      qrCodeUrl: json['qrCodeUrl'],
      discount: json['discount'] ?? '',
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isOnline: json['isOnline'] ?? true,
      isInStore: json['isInStore'] ?? true,
      isPremium: json['isPremium'] ?? false,
      price: json['price']?.toDouble(),
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((e) => Category.fromJson(e))
              .toList()
          : [],
      isSaved: json['isSaved'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Coupon copyWith({bool? isSaved}) {
    return Coupon(
      id: id,
      title: title,
      storeId: storeId,
      code: code,
      barcodeUrl: barcodeUrl,
      qrCodeUrl: qrCodeUrl,
      discount: discount,
      description: description,
      startDate: startDate,
      endDate: endDate,
      isOnline: isOnline,
      isInStore: isInStore,
      isPremium: isPremium,
      price: price,
      store: store,
      categories: categories,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActive => DateTime.now().isAfter(startDate) && !isExpired;

  int get daysUntilExpiry {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }
}

// Coupons Service
class CouponsService {
  final Dio _dio;

  CouponsService(this._dio);

  Future<List<Coupon>> getCoupons({
    String? storeId,
    String? categoryId,
    bool? isOnline,
    bool? isInStore,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storeId != null) queryParams['storeId'] = storeId;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isOnline != null) queryParams['isOnline'] = isOnline;
      if (isInStore != null) queryParams['isInStore'] = isInStore;

      final response = await _dio.get('/coupons', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> couponsJson =
            response.data['coupons'] ?? response.data;
        return couponsJson.map((json) => Coupon.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching coupons: $e');
      return [];
    }
  }

  Future<Coupon?> getCouponById(String id) async {
    try {
      final response = await _dio.get('/coupons/$id');

      if (response.statusCode == 200) {
        return Coupon.fromJson(response.data['coupon'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching coupon: $e');
      return null;
    }
  }

  Future<bool> saveCoupon(String couponId, String userEmail) async {
    try {
      final response = await _dio.post(
        '/coupons/save',
        data: {'couponId': couponId},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error saving coupon: $e');
      return false;
    }
  }

  Future<bool> unsaveCoupon(String couponId, String userEmail) async {
    try {
      final response = await _dio.post(
        '/coupons/unsave',
        data: {'couponId': couponId},
        options: Options(headers: {'user-email': userEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error unsaving coupon: $e');
      return false;
    }
  }

  Future<List<Coupon>> getUserCoupons(String userId, String userEmail) async {
    try {
      final response = await _dio.get(
        '/users/$userId/coupons',
        options: Options(headers: {'user-email': userEmail}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> couponsJson =
            response.data['coupons'] ?? response.data;
        return couponsJson.map((json) => Coupon.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user coupons: $e');
      return [];
    }
  }
}

// Filter State
class CouponFilters {
  final String? storeId;
  final String? categoryId;
  final bool? isOnline;
  final bool? isInStore;
  final String? searchQuery;
  final bool showExpiredOnly;
  final bool showActiveOnly;

  CouponFilters({
    this.storeId,
    this.categoryId,
    this.isOnline,
    this.isInStore,
    this.searchQuery,
    this.showExpiredOnly = false,
    this.showActiveOnly = false,
  });

  CouponFilters copyWith({
    String? storeId,
    String? categoryId,
    bool? isOnline,
    bool? isInStore,
    String? searchQuery,
    bool? showExpiredOnly,
    bool? showActiveOnly,
  }) {
    return CouponFilters(
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      isOnline: isOnline ?? this.isOnline,
      isInStore: isInStore ?? this.isInStore,
      searchQuery: searchQuery ?? this.searchQuery,
      showExpiredOnly: showExpiredOnly ?? this.showExpiredOnly,
      showActiveOnly: showActiveOnly ?? this.showActiveOnly,
    );
  }
}

// Providers
final couponsServiceProvider = Provider<CouponsService>((ref) {
  final dio = ref.read(dioProvider);
  return CouponsService(dio);
});

final couponFiltersProvider =
    StateProvider<CouponFilters>((ref) => CouponFilters());

final couponsProvider =
    FutureProvider.family<List<Coupon>, CouponFilters>((ref, filters) async {
  final service = ref.read(couponsServiceProvider);
  final coupons = await service.getCoupons(
    storeId: filters.storeId,
    categoryId: filters.categoryId,
    isOnline: filters.isOnline,
    isInStore: filters.isInStore,
  );

  // Apply local filters
  var filteredCoupons = coupons;

  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    filteredCoupons = filteredCoupons
        .where((coupon) =>
            coupon.title
                .toLowerCase()
                .contains(filters.searchQuery!.toLowerCase()) ||
            coupon.store?.name
                    .toLowerCase()
                    .contains(filters.searchQuery!.toLowerCase()) ==
                true)
        .toList();
  }

  if (filters.showExpiredOnly) {
    filteredCoupons =
        filteredCoupons.where((coupon) => coupon.isExpired).toList();
  } else if (filters.showActiveOnly) {
    filteredCoupons =
        filteredCoupons.where((coupon) => coupon.isActive).toList();
  }

  return filteredCoupons;
});

final savedCouponsStateProvider = StateProvider<Set<String>>((ref) => {});

// CouponsTab Widget
class CouponsTab extends ConsumerStatefulWidget {
  const CouponsTab({super.key});

  @override
  ConsumerState<CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends ConsumerState<CouponsTab> {
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
    final filters = ref.watch(couponFiltersProvider);
    final couponsAsync = ref.watch(couponsProvider(filters));

    return Column(
      children: [
        // Search and Filter Header
        _buildSearchAndFilterHeader(),

        // Filter Chips
        _buildFilterChips(),

        // Coupons Content
        Expanded(
          child: couponsAsync.when(
            data: (coupons) => _buildCouponsContent(coupons),
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
                hintText: 'Search coupons...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(couponFiltersProvider.notifier).update(
                                (state) => state.copyWith(searchQuery: ''),
                              );
                        },
                      )
                    : null,
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
                ref.read(couponFiltersProvider.notifier).update(
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

  Widget _buildFilterChips() {
    final filters = ref.watch(couponFiltersProvider);

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
                  label: 'Online',
                  isSelected: filters.isOnline == true,
                  onTap: () => _toggleOnlineFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'In-Store',
                  isSelected: filters.isInStore == true,
                  onTap: () => _toggleInStoreFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Active',
                  isSelected: filters.showActiveOnly,
                  onTap: () => _toggleActiveFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Expired',
                  isSelected: filters.showExpiredOnly,
                  onTap: () => _toggleExpiredFilter(),
                ),
                const SizedBox(width: 8),
                if (_hasActiveFilters(filters))
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

  Widget _buildCouponsContent(List<Coupon> coupons) {
    if (coupons.isEmpty) {
      return _buildEmptyState();
    }

    // Separate coupons by status
    final activeCoupons = coupons.where((c) => c.isActive).toList();
    final expiringSoonCoupons =
        activeCoupons.where((c) => c.daysUntilExpiry <= 3).toList();
    final expiredCoupons = coupons.where((c) => c.isExpired).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(couponsProvider);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Expiring Soon Section
          if (expiringSoonCoupons.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Expiring Soon',
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCouponCard(
                      expiringSoonCoupons[index],
                      isExpiringSoon: true),
                  childCount: expiringSoonCoupons.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // Active Coupons Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Available Coupons',
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
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCouponCard(activeCoupons[index]),
                childCount: activeCoupons.length,
              ),
            ),
          ),

          // Expired Coupons Section
          if (expiredCoupons.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Expired Coupons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildCouponCard(expiredCoupons[index], isExpired: true),
                  childCount: expiredCoupons.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon,
      {bool isExpiringSoon = false, bool isExpired = false}) {
    final savedCoupons = ref.watch(savedCouponsStateProvider);
    final isSaved = savedCoupons.contains(coupon.id) || coupon.isSaved;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isExpiringSoon ? Border.all(color: Colors.orange, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isExpired ? 0.02 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: isExpired ? 0.6 : 1.0,
        child: InkWell(
          onTap: isExpired ? null : () => _showCouponDetails(coupon),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: coupon.store?.logo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                coupon.store!.logo!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.store, color: Colors.grey),
                              ),
                            )
                          : const Icon(Icons.store, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),

                    // Store Name and Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (coupon.store != null)
                            Text(
                              coupon.store!.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Text(
                            coupon.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Save Button
                    if (!isExpired)
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color:
                              isSaved ? const Color(0xFF6366F1) : Colors.grey,
                        ),
                        onPressed: () => _toggleSaveCoupon(coupon),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Discount Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isExpired
                          ? [Colors.grey[400]!, Colors.grey[500]!]
                          : [const Color(0xFF10B981), const Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    coupon.discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (coupon.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    coupon.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                // Footer Row
                Row(
                  children: [
                    // Usage Type Badges
                    if (coupon.isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (coupon.isOnline && coupon.isInStore)
                      const SizedBox(width: 8),
                    if (coupon.isInStore)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'In-Store',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Expiry Info
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
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
                    else if (isExpiringSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Expires in ${coupon.daysUntilExpiry} days',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Expires ${_formatDate(coupon.endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Premium Badge
                if (coupon.isPremium)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.purple[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
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
            'Failed to load coupons',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(couponsProvider),
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
          const Icon(Icons.confirmation_number_outlined,
              size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No coupons found',
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
      builder: (context) => const CouponFiltersBottomSheet(),
    );
  }

  void _toggleOnlineFilter() {
    final notifier = ref.read(couponFiltersProvider.notifier);
    final current = ref.read(couponFiltersProvider).isOnline;
    notifier.update(
        (state) => state.copyWith(isOnline: current == true ? null : true));
  }

  void _toggleInStoreFilter() {
    final notifier = ref.read(couponFiltersProvider.notifier);
    final current = ref.read(couponFiltersProvider).isInStore;
    notifier.update(
        (state) => state.copyWith(isInStore: current == true ? null : true));
  }

  void _toggleActiveFilter() {
    final notifier = ref.read(couponFiltersProvider.notifier);
    final current = ref.read(couponFiltersProvider).showActiveOnly;
    notifier.update((state) => state.copyWith(
          showActiveOnly: !current,
          showExpiredOnly: false,
        ));
  }

  void _toggleExpiredFilter() {
    final notifier = ref.read(couponFiltersProvider.notifier);
    final current = ref.read(couponFiltersProvider).showExpiredOnly;
    notifier.update((state) => state.copyWith(
          showExpiredOnly: !current,
          showActiveOnly: false,
        ));
  }

  bool _hasActiveFilters(CouponFilters filters) {
    return filters.storeId != null ||
        filters.categoryId != null ||
        filters.isOnline != null ||
        filters.isInStore != null ||
        filters.showActiveOnly ||
        filters.showExpiredOnly;
  }

  void _clearAllFilters() {
    ref.read(couponFiltersProvider.notifier).state = CouponFilters();
    _searchController.clear();
  }

  Future<void> _toggleSaveCoupon(Coupon coupon) async {
    final user = ref.read(currentBackendUserProvider);
    if (user == null) return;

    final service = ref.read(couponsServiceProvider);
    final savedCoupons = ref.read(savedCouponsStateProvider.notifier);
    final isSaved = ref.read(savedCouponsStateProvider).contains(coupon.id);

    bool success;
    if (isSaved) {
      success = await service.unsaveCoupon(coupon.id, user.email);
      if (success) {
        savedCoupons.update((state) => state..remove(coupon.id));
      }
    } else {
      success = await service.saveCoupon(coupon.id, user.email);
      if (success) {
        savedCoupons.update((state) => state..add(coupon.id));
      }
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved
              ? 'Coupon removed from saved'
              : 'Coupon saved successfully!'),
          backgroundColor: isSaved ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  void _showCouponDetails(Coupon coupon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CouponDetailsModal(coupon: coupon),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Coupon Details Modal
class CouponDetailsModal extends ConsumerWidget {
  final Coupon coupon;

  const CouponDetailsModal({super.key, required this.coupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Store Logo
                if (coupon.store?.logo != null)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        coupon.store!.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                  ),
                if (coupon.store?.logo != null) const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (coupon.store != null)
                        Text(
                          coupon.store!.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(
                        coupon.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        coupon.discount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description
                  if (coupon.description != null) ...[
                    _buildSectionTitle('Description'),
                    const SizedBox(height: 8),
                    Text(
                      coupon.description!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Coupon Code Section
                  if (coupon.code != null) ...[
                    _buildSectionTitle('Coupon Code'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            coupon.code!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _copyToClipboard(context, coupon.code!),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy Code'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // QR Code Section
                  if (coupon.qrCodeUrl != null || coupon.code != null) ...[
                    _buildSectionTitle('QR Code'),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data:
                                  coupon.qrCodeUrl ?? coupon.code ?? coupon.id,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Show this QR code at checkout',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Usage Information
                  _buildSectionTitle('Usage Information'),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            'Valid From', _formatDate(coupon.startDate)),
                        _buildInfoRow(
                            'Valid Until', _formatDate(coupon.endDate)),
                        _buildInfoRow(
                            'Online Use', coupon.isOnline ? 'Yes' : 'No'),
                        _buildInfoRow(
                            'In-Store Use', coupon.isInStore ? 'Yes' : 'No'),
                        if (coupon.isPremium)
                          _buildInfoRow('Type', 'Premium Coupon'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Usage Guidelines
                  _buildSectionTitle('How to Use'),
                  const SizedBox(height: 12),

                  if (coupon.isOnline && coupon.isInStore) ...[
                    _buildUsageStep(
                      icon: Icons.computer,
                      title: 'For Online Orders',
                      description:
                          'Copy the coupon code and paste it at checkout',
                    ),
                    const SizedBox(height: 12),
                    _buildUsageStep(
                      icon: Icons.store,
                      title: 'For In-Store Purchase',
                      description:
                          'Show the QR code or mention the coupon code at checkout',
                    ),
                  ] else if (coupon.isOnline) ...[
                    _buildUsageStep(
                      icon: Icons.computer,
                      title: 'Online Only',
                      description:
                          'Copy the coupon code and paste it during online checkout',
                    ),
                  ] else if (coupon.isInStore) ...[
                    _buildUsageStep(
                      icon: Icons.store,
                      title: 'In-Store Only',
                      description:
                          'Show the QR code or mention the coupon code at the store',
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareCoupon(coupon),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _saveCoupon(context, ref, coupon),
                          icon: const Icon(Icons.bookmark),
                          label: const Text('Save Coupon'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon code copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareCoupon(Coupon coupon) {
    // TODO: Implement share functionality
    print('Sharing coupon: ${coupon.title}');
  }

  void _saveCoupon(BuildContext context, WidgetRef ref, Coupon coupon) {
    // TODO: Implement save coupon logic
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Filter Bottom Sheet
class CouponFiltersBottomSheet extends ConsumerWidget {
  const CouponFiltersBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(couponFiltersProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Filter Coupons',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Store Filter
          const Text('Store', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: filters.storeId,
            decoration: InputDecoration(
              hintText: 'Select a store',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [], // TODO: Populate with actual stores
            onChanged: (value) {
              ref.read(couponFiltersProvider.notifier).update(
                    (state) => state.copyWith(storeId: value),
                  );
            },
          ),

          const SizedBox(height: 20),

          // Category Filter
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: filters.categoryId,
            decoration: InputDecoration(
              hintText: 'Select a category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [], // TODO: Populate with actual categories
            onChanged: (value) {
              ref.read(couponFiltersProvider.notifier).update(
                    (state) => state.copyWith(categoryId: value),
                  );
            },
          ),

          const SizedBox(height: 20),

          // Usage Type Filters
          const Text('Usage Type',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          CheckboxListTile(
            title: const Text('Online'),
            value: filters.isOnline ?? false,
            onChanged: (value) {
              ref.read(couponFiltersProvider.notifier).update(
                    (state) => state.copyWith(isOnline: value),
                  );
            },
            contentPadding: EdgeInsets.zero,
          ),

          CheckboxListTile(
            title: const Text('In-Store'),
            value: filters.isInStore ?? false,
            onChanged: (value) {
              ref.read(couponFiltersProvider.notifier).update(
                    (state) => state.copyWith(isInStore: value),
                  );
            },
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 20),

          // Status Filters
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          CheckboxListTile(
            title: const Text('Active Only'),
            value: filters.showActiveOnly,
            onChanged: (value) {
              ref.read(couponFiltersProvider.notifier).update(
                    (state) => state.copyWith(
                      showActiveOnly: value ?? false,
                      showExpiredOnly: false,
                    ),
                  );
            },
            contentPadding: EdgeInsets.zero,
          ),

          CheckboxListTile(
            title: const Text('Expired Only'),
            value: filters.showExpiredOnly,
            onChanged: (value) {
              ref.read(couponFiltersProvider.notifier).update(
                    (state) => state.copyWith(
                      showExpiredOnly: value ?? false,
                      showActiveOnly: false,
                    ),
                  );
            },
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(couponFiltersProvider.notifier).state =
                        CouponFilters();
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
