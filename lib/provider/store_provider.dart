import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';

// Store State
class StoreState {
  final List<StoreModel> stores;
  final List<StoreModel> nearbyStores;
  final bool isLoading;
  final String? error;

  StoreState({
    this.stores = const [],
    this.nearbyStores = const [],
    this.isLoading = false,
    this.error,
  });

  StoreState copyWith({
    List<StoreModel>? stores,
    List<StoreModel>? nearbyStores,
    bool? isLoading,
    String? error,
  }) {
    return StoreState(
      stores: stores ?? this.stores,
      nearbyStores: nearbyStores ?? this.nearbyStores,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Store Notifier
class StoreNotifier extends StateNotifier<StoreState> {
  final StoreService _storeService;

  StoreNotifier(this._storeService) : super(StoreState());

  Future<void> loadStores({String? search, String? city}) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _storeService.getAllStores(
      search: search,
      city: city,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        stores: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load stores',
        isLoading: false,
      );
    }
  }

  Future<void> loadNearbyStores({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _storeService.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        nearbyStores: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load nearby stores',
        isLoading: false,
      );
    }
  }

  Future<void> searchStores(String query) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _storeService.searchStores(query);

    if (response.success && response.data != null) {
      state = state.copyWith(
        stores: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to search stores',
        isLoading: false,
      );
    }
  }
}

// Provider
final storeProvider = StateNotifierProvider<StoreNotifier, StoreState>((ref) {
  final storeService = ref.watch(storeServiceProvider);
  return StoreNotifier(storeService);
});

// Individual Store Provider
final storeDetailProvider =
    FutureProvider.family<StoreModel?, String>((ref, storeId) async {
  final storeService = ref.watch(storeServiceProvider);
  final response = await storeService.getStoreDetail(storeId);
  return response.success ? response.data : null;
});
