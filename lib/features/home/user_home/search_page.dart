import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus search field when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildSearchAppBar(),
      body: _buildSearchBody(),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search deals, stores, products...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _isSearching = value.isNotEmpty;
          });
        },
        onSubmitted: (value) => _performSearch(value),
      ),
      actions: [
        if (_searchQuery.isNotEmpty)
          TextButton(
            onPressed: () => _performSearch(_searchQuery),
            child: const Text('Search'),
          ),
      ],
    );
  }

  Widget _buildSearchBody() {
    if (_isSearching && _searchQuery.isNotEmpty) {
      return _buildSearchResults();
    } else {
      return _buildSearchSuggestions();
    }
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          _buildRecentSearches(),
          const SizedBox(height: 24),

          // Popular Categories
          _buildPopularCategories(),
          const SizedBox(height: 24),

          // Trending Searches
          _buildTrendingSearches(),
          const SizedBox(height: 24),

          // Quick Filters
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      'Electronics deals',
      'Grocery coupons',
      'Fashion sale',
      'Best Buy',
      'Target offers',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () => _clearRecentSearches(),
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentSearches.length,
          itemBuilder: (context, index) {
            final search = recentSearches[index];
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(search),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => _removeRecentSearch(search),
              ),
              onTap: () => _selectSearch(search),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularCategories() {
    final categories = [
      {
        'name': 'Electronics',
        'icon': Icons.phone_android,
        'color': Colors.blue
      },
      {'name': 'Groceries', 'icon': Icons.shopping_cart, 'color': Colors.green},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Home & Garden', 'icon': Icons.home, 'color': Colors.orange},
      {
        'name': 'Beauty',
        'icon': Icons.face_retouching_natural,
        'color': Colors.purple
      },
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () => _selectSearch(category['name'] as String),
              child: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendingSearches() {
    final trendingSearches = [
      '🔥 Black Friday deals',
      '⚡ Flash sales',
      '💰 50% off electronics',
      '🛒 Grocery discounts',
      '👕 Fashion week',
      '🏠 Home appliances',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trendingSearches.map((search) {
            return GestureDetector(
              onTap: () => _selectSearch(
                  search.replaceAll(RegExp(r'[^\w\s]'), '').trim()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6366F1)),
                ),
                child: Text(
                  search,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final filters = [
      {'name': 'Near Me', 'icon': Icons.location_on},
      {'name': 'Expiring Soon', 'icon': Icons.timer},
      {'name': 'Free Shipping', 'icon': Icons.local_shipping},
      {'name': 'Best Deals', 'icon': Icons.star},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Filters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.0,
          ),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            return GestureDetector(
              onTap: () => _applyFilter(filter['name'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      color: const Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search filters
          _buildSearchFilters(),
          const SizedBox(height: 16),

          // Results count
          Text(
            'Found 23 results for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),

          // Mock search results
          _buildMockResults(),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    final filters = ['All', 'Flyers', 'Coupons', 'Stores', 'Near Me'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = index == 0; // Mock selection

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _filterResults(filter),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF6366F1).withOpacity(0.1),
              checkmarkColor: const Color(0xFF6366F1),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMockResults() {
    final results = [
      {
        'type': 'Flyer',
        'title': 'Electronics Mega Sale',
        'store': 'Best Buy',
        'discount': '40% OFF',
        'endDate': 'Ends in 2 days',
      },
      {
        'type': 'Coupon',
        'title': '20% Off Your Purchase',
        'store': 'Target',
        'discount': '20% OFF',
        'endDate': 'Expires tomorrow',
      },
      {
        'type': 'Store',
        'title': 'Walmart Supercenter',
        'store': 'Walmart',
        'discount': 'Multiple deals',
        'endDate': '0.5 km away',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(result['type'] as String).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result['type'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: _getTypeColor(result['type'] as String),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              result['title'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(result['store'] as String),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result['discount'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      result['endDate'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _openResult(result),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'flyer':
        return Colors.blue;
      case 'coupon':
        return Colors.green;
      case 'store':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Action methods
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });
    // TODO: Implement actual search functionality
  }

  void _selectSearch(String search) {
    _searchController.text = search;
    _performSearch(search);
  }

  void _clearRecentSearches() {
    // TODO: Implement clear recent searches
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recent searches cleared')),
    );
  }

  void _removeRecentSearch(String search) {
    // TODO: Implement remove specific recent search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed "$search" from recent searches')),
    );
  }

  void _applyFilter(String filter) {
    // TODO: Implement filter application
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied filter: $filter')),
    );
  }

  void _filterResults(String filter) {
    // TODO: Implement result filtering
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filtering by: $filter')),
    );
  }

  void _openResult(Map<String, dynamic> result) {
    // TODO: Navigate to result details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: ${result['title']}')),
    );
  }
}
