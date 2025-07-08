import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/provider/category_provider.dart';
import 'package:topprix/provider/coupon_provider.dart';
import 'package:topprix/provider/flyer_provider.dart';
import 'package:topprix/provider/location_provider.dart';
import 'package:topprix/provider/store_provider.dart';
import '../models/flyer_model.dart';
import '../models/coupon_model.dart';
import '../models/store_model.dart';
import '../models/category_model.dart';

// Home Dashboard State
class HomeDashboardState {
  final List<FlyerModel> featuredFlyers;
  final List<FlyerModel> trendingFlyers;
  final List<CouponModel> featuredCoupons;
  final List<StoreModel> nearbyStores;
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;

  HomeDashboardState({
    this.featuredFlyers = const [],
    this.trendingFlyers = const [],
    this.featuredCoupons = const [],
    this.nearbyStores = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  HomeDashboardState copyWith({
    List<FlyerModel>? featuredFlyers,
    List<FlyerModel>? trendingFlyers,
    List<CouponModel>? featuredCoupons,
    List<StoreModel>? nearbyStores,
    List<CategoryModel>? categories,
    bool? isLoading,
    String? error,
  }) {
    return HomeDashboardState(
      featuredFlyers: featuredFlyers ?? this.featuredFlyers,
      trendingFlyers: trendingFlyers ?? this.trendingFlyers,
      featuredCoupons: featuredCoupons ?? this.featuredCoupons,
      nearbyStores: nearbyStores ?? this.nearbyStores,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Home Dashboard Notifier
class HomeDashboardNotifier extends StateNotifier<HomeDashboardState> {
  HomeDashboardNotifier() : super(HomeDashboardState());

  Future<void> loadDashboardData(WidgetRef ref) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all dashboard data concurrently
      await Future.wait([
        ref.read(flyerProvider.notifier).loadFeaturedFlyers(),
        ref.read(flyerProvider.notifier).loadTrendingFlyers(),
        ref.read(couponProvider.notifier).loadCoupons(refresh: true),
        _loadLocationBasedData(ref),
      ] as Iterable<Future>);

      // Get the loaded data from providers
      final flyerState = ref.read(flyerProvider);
      final couponState = ref.read(couponProvider);
      final storeState = ref.read(storeProvider);
      final categories = await ref.read(categoriesProvider.future);

      state = state.copyWith(
        featuredFlyers: flyerState.featuredFlyers,
        trendingFlyers: flyerState.trendingFlyers.take(5).toList(),
        featuredCoupons: couponState.coupons.take(5).toList(),
        nearbyStores: storeState.nearbyStores.take(3).toList(),
        categories: categories.take(8).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load dashboard data',
        isLoading: false,
      );
    }
  }

  Future<void> _loadLocationBasedData(WidgetRef ref) async {
    final locationNotifier = ref.read(locationProvider.notifier);
    await locationNotifier.getCurrentLocation();

    final location = ref.read(locationProvider).position;
    if (location != null) {
      await ref.read(storeProvider.notifier).loadNearbyStores(
            latitude: location.latitude,
            longitude: location.longitude,
          );
    }
  }

  Future<void> refresh(WidgetRef ref) async {
    await loadDashboardData(ref);
  }
}

// Provider
final homeDashboardProvider =
    StateNotifierProvider<HomeDashboardNotifier, HomeDashboardState>((ref) {
  return HomeDashboardNotifier();
});
