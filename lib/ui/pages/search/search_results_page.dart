// lib/ui/pages/search/search_results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Search State Provider
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchState {
  final String query;
  final List<SearchResult> results;
  final bool isLoading;
  final String? error;
  final SearchFilter filter;
  final String sortBy;

  SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.filter = const SearchFilter(),
    this.sortBy = 'relevance',
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isLoading,
    String? error,
    SearchFilter? filter,
    String? sortBy,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class SearchFilter {
  final String? category;
  final String? store;
  final double? minDiscount;
  final double? maxDistance;
  final bool showExpiring;
  final List<String> dealTypes;

  const SearchFilter({
    this.category,
    this.store,
    this.minDiscount,
    this.maxDistance,
    this.showExpiring = false,
    this.dealTypes = const ['flyers', 'coupons', 'deals'],
  });

  SearchFilter copyWith({
    String? category,
    String? store,
    double? minDiscount,
    double? maxDistance,
    bool? showExpiring,
    List<String>? dealTypes,
  }) {
    return SearchFilter(
      category: category ?? this.category,
      store: store ?? this.store,
      minDiscount: minDiscount ?? this.minDiscount,
      maxDistance: maxDistance ?? this.maxDistance,
      showExpiring: showExpiring ?? this.showExpiring,
      dealTypes: dealTypes ?? this.dealTypes,
    );
  }
}

class SearchResult {
  final String id;
  final String title;
  final String store;
  final String type; // 'flyer', 'coupon', 'deal'
  final String? imageUrl;
  final String? discount;
  final DateTime? endDate;
  final double? distance;
  final String? category;
  final double? originalPrice;
  final double? salePrice;

  SearchResult({
    required this.id,
    required this.title,
    required this.store,
    required this.type,
    this.imageUrl,
    this.discount,
    this.endDate,
    this.distance,
    this.category,
    this.originalPrice,
    this.salePrice,
  });
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, query: query, error: null);

    try {
      // Simulate API call - replace with actual search service
      await Future.delayed(const Duration(seconds: 1));

      // Mock search results
      final results = _generateMockResults(query);

      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void updateFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
    _applyFilters();
  }

  void updateSort(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _applySorting();
  }

  void _applyFilters() {
    // Apply filters to results
    // This would filter the existing results based on filter criteria
  }

  void _applySorting() {
    final sortedResults = List<SearchResult>.from(state.results);

    switch (state.sortBy) {
      case 'distance':
        sortedResults
            .sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        break;
      case 'discount':
        sortedResults.sort((a, b) {
          final aDiscount =
              double.tryParse(a.discount?.replaceAll('%', '') ?? '0') ?? 0;
          final bDiscount =
              double.tryParse(b.discount?.replaceAll('%', '') ?? '0') ?? 0;
          return bDiscount.compareTo(aDiscount);
        });
        break;
      case 'expiry':
        sortedResults.sort((a, b) => (a.endDate ?? DateTime.now())
            .compareTo(b.endDate ?? DateTime.now()));
        break;
      case 'relevance':
      default:
        // Keep original order for relevance
        break;
    }

    state = state.copyWith(results: sortedResults);
  }

  List<SearchResult> _generateMockResults(String query) {
    // Mock results - replace with actual API data
    return [
      SearchResult(
        id: '1',
        title: 'Summer Sale - Electronics',
        store: 'TechZone',
        type: 'flyer',
        imageUrl: 'https://via.placeholder.com/200x150',
        discount: '50%',
        endDate: DateTime.now().add(const Duration(days: 3)),
        distance: 0.5,
        category: 'Electronics',
      ),
      SearchResult(
        id: '2',
        title: '20% Off Groceries',
        store: 'FreshMart',
        type: 'coupon',
        discount: '20%',
        endDate: DateTime.now().add(const Duration(days: 7)),
        distance: 1.2,
        category: 'Groceries',
      ),
      SearchResult(
        id: '3',
        title: 'Fashion Week Special',
        store: 'StyleHub',
        type: 'deal',
        imageUrl: 'https://via.placeholder.com/200x150',
        discount: '70%',
        endDate: DateTime.now().add(const Duration(days: 5)),
        distance: 2.1,
        category: 'Fashion',
        originalPrice: 100.0,
        salePrice: 30.0,
      ),
    ];
  }
}

class SearchResultsPage extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsPage({
    super.key,
    required this.query,
  });

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _tabController = TabController(length: 4, vsync: this);

    // Trigger search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).search(widget.query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: _buildSearchBar(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              _buildFilterBar(),
              _buildTabBar(),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilterPanel(),
          Expanded(
            child: _buildSearchResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            ref.read(searchProvider.notifier).search(query);
          }
        },
        decoration: const InputDecoration(
          hintText: 'Search stores, products, deals...',
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Sort', Icons.sort, () {
                    _showSortDialog();
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Distance', Icons.location_on, () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Category', Icons.category, () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Store', Icons.store, () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  }),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.close : Icons.tune,
              color: const Color(0xFF2196F3),
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2196F3)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2196F3),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF2196F3),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Flyers'),
          Tab(text: 'Coupons'),
          Tab(text: 'Deals'),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Category',
                  ['All', 'Groceries', 'Electronics', 'Fashion', 'Home'],
                  'All',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  'Distance',
                  ['Any', '1 km', '5 km', '10 km', '25 km'],
                  'Any',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Min Discount',
                  ['Any', '10%', '20%', '30%', '50%'],
                  'Any',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    setState(() {
                      _showFilters = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> items, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (newValue) {
                // Handle dropdown change
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchState.error!,
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(searchProvider.notifier).search(searchState.query);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildResultsList(searchState.results),
        _buildResultsList(
            searchState.results.where((r) => r.type == 'flyer').toList()),
        _buildResultsList(
            searchState.results.where((r) => r.type == 'coupon').toList()),
        _buildResultsList(
            searchState.results.where((r) => r.type == 'deal').toList()),
      ],
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildResultCard(results[index]);
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        onTap: () {
          // Navigate to detail page based on type
          switch (result.type) {
            case 'flyer':
              context.push('/flyer/${result.id}');
              break;
            case 'coupon':
              context.push('/coupon/${result.id}');
              break;
            case 'deal':
              context.push('/deal/${result.id}');
              break;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: result.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          result.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 32);
                          },
                        ),
                      )
                    : Icon(
                        _getTypeIcon(result.type),
                        size: 32,
                        color: Colors.grey[400],
                      ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(result.type),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (result.discount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5722),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${result.discount} OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.store,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (result.distance != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${result.distance!.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (result.endDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires ${_formatDate(result.endDate!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'flyer':
        return Icons.receipt_long;
      case 'coupon':
        return Icons.local_offer;
      case 'deal':
        return Icons.flash_on;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'flyer':
        return const Color(0xFF2196F3);
      case 'coupon':
        return const Color(0xFF4CAF50);
      case 'deal':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'tomorrow';
    } else if (difference < 7) {
      return 'in $difference days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Relevance'),
                onTap: () {
                  ref.read(searchProvider.notifier).updateSort('relevance');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Distance'),
                onTap: () {
                  ref.read(searchProvider.notifier).updateSort('distance');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Discount'),
                onTap: () {
                  ref.read(searchProvider.notifier).updateSort('discount');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Expiry Date'),
                onTap: () {
                  ref.read(searchProvider.notifier).updateSort('expiry');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
