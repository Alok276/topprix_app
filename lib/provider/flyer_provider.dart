// lib/providers/flyer_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flyer_model.dart';
import '../services/flyer_service.dart';

// Flyer State
class FlyerState {
  final List<FlyerModel> flyers;
  final List<FlyerModel> featuredFlyers;
  final List<FlyerModel> trendingFlyers;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  FlyerState({
    this.flyers = const [],
    this.featuredFlyers = const [],
    this.trendingFlyers = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  FlyerState copyWith({
    List<FlyerModel>? flyers,
    List<FlyerModel>? featuredFlyers,
    List<FlyerModel>? trendingFlyers,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return FlyerState(
      flyers: flyers ?? this.flyers,
      featuredFlyers: featuredFlyers ?? this.featuredFlyers,
      trendingFlyers: trendingFlyers ?? this.trendingFlyers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Flyer Notifier
class FlyerNotifier extends StateNotifier<FlyerState> {
  final FlyerService _flyerService;

  FlyerNotifier(this._flyerService) : super(FlyerState());

  Future<void> loadFeaturedFlyers() async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _flyerService.getFeaturedFlyers();

    if (response.success && response.data != null) {
      state = state.copyWith(
        featuredFlyers: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load featured flyers',
        isLoading: false,
      );
    }
  }

  Future<void> loadTrendingFlyers() async {
    if (state.trendingFlyers.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final response = await _flyerService.getTrendingFlyers();

    if (response.success && response.data != null) {
      state = state.copyWith(
        trendingFlyers: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load trending flyers',
        isLoading: false,
      );
    }
  }

  Future<void> loadFlyers({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        flyers: [],
        currentPage: 1,
        hasMore: true,
        isLoading: true,
        error: null,
      );
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true);
    }

    final response = await _flyerService.getTrendingFlyers();

    if (response.success && response.data != null) {
      final newFlyers = response.data!;

      state = state.copyWith(
        flyers: refresh ? newFlyers : [...state.flyers, ...newFlyers],
        isLoading: false,
        hasMore: newFlyers.length >= 20, // Assuming 20 is the page size
        currentPage: refresh ? 2 : state.currentPage + 1,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load flyers',
        isLoading: false,
      );
    }
  }

  Future<void> loadFlyersByStore(String storeId) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _flyerService.getFlyersByStore(storeId);

    if (response.success && response.data != null) {
      state = state.copyWith(
        flyers: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load store flyers',
        isLoading: false,
      );
    }
  }

  Future<void> loadFlyersByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _flyerService.getFlyersByCategory(categoryId);

    if (response.success && response.data != null) {
      state = state.copyWith(
        flyers: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load category flyers',
        isLoading: false,
      );
    }
  }

  Future<bool> saveFlyer(String flyerId) async {
    final response = await _flyerService.saveFlyer(flyerId);
    return response.success;
  }
}

// Provider
final flyerProvider = StateNotifierProvider<FlyerNotifier, FlyerState>((ref) {
  final flyerService = ref.watch(flyerServiceProvider);
  return FlyerNotifier(flyerService);
});

// Individual Flyer Provider
final flyerDetailProvider =
    FutureProvider.family<FlyerModel?, String>((ref, flyerId) async {
  final flyerService = ref.watch(flyerServiceProvider);
  final response = await flyerService.getFlyerDetail(flyerId);
  return response.success ? response.data : null;
});
