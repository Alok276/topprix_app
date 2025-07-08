import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_response.dart';
import '../services/search_service.dart';

// Search State
class SearchState {
  final String query;
  final Map<String, dynamic>? results;
  final bool isLoading;
  final String? error;
  final SearchFilter filter;
  final String sortBy;

  SearchState({
    this.query = '',
    this.results,
    this.isLoading = false,
    this.error,
    this.filter = const SearchFilter(),
    this.sortBy = 'relevance',
  });

  SearchState copyWith({
    String? query,
    Map<String, dynamic>? results,
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

// Search Filter
class SearchFilter {
  final String? categoryId;
  final String? storeId;
  final double? minDiscount;
  final double? maxDistance;
  final bool showExpiring;
  final List<String> dealTypes;

  const SearchFilter({
    this.categoryId,
    this.storeId,
    this.minDiscount,
    this.maxDistance,
    this.showExpiring = false,
    this.dealTypes = const ['flyers', 'coupons'],
  });

  SearchFilter copyWith({
    String? categoryId,
    String? storeId,
    double? minDiscount,
    double? maxDistance,
    bool? showExpiring,
    List<String>? dealTypes,
  }) {
    return SearchFilter(
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      minDiscount: minDiscount ?? this.minDiscount,
      maxDistance: maxDistance ?? this.maxDistance,
      showExpiring: showExpiring ?? this.showExpiring,
      dealTypes: dealTypes ?? this.dealTypes,
    );
  }
}

// Search Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;

  SearchNotifier(this._searchService) : super(SearchState());

  Future<void> search(String query) async {
    state = state.copyWith(
      isLoading: true,
      query: query,
      error: null,
    );

    final response = await _searchService.searchDeals(
      query: query,
      categoryId: state.filter.categoryId,
      storeId: state.filter.storeId,
      minDiscount: state.filter.minDiscount,
      maxDistance: state.filter.maxDistance,
      showExpiring: state.filter.showExpiring,
      dealTypes: state.filter.dealTypes,
      sortBy: state.sortBy,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        results: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to search',
        isLoading: false,
      );
    }
  }

  void updateFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  void updateSort(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  void clearSearch() {
    state = SearchState();
  }
}

// Provider
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final searchService = ref.watch(searchServiceProvider);
  return SearchNotifier(searchService);
});
