import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/api_response.dart';
import '../services/location_service.dart';

// Location State
class LocationState {
  final Position? position;
  final bool isLoading;
  final String? error;
  final bool hasPermission;

  LocationState({
    this.position,
    this.isLoading = false,
    this.error,
    this.hasPermission = false,
  });

  LocationState copyWith({
    Position? position,
    bool? isLoading,
    String? error,
    bool? hasPermission,
  }) {
    return LocationState(
      position: position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

// Location Notifier
class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _locationService.getCurrentLocation();

    if (response.success && response.data != null) {
      state = state.copyWith(
        position: response.data!,
        isLoading: false,
        hasPermission: true,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to get location',
        isLoading: false,
        hasPermission: false,
      );
    }
  }

  Future<Map<String, dynamic>?> getNearbyDeals({
    String? dealType,
    String? categoryId,
    String sortBy = 'distance',
    int limit = 20,
  }) async {
    if (state.position == null) {
      await getCurrentLocation();
      if (state.position == null) return null;
    }

    final response = await _locationService.getNearbyDeals(
      latitude: state.position!.latitude,
      longitude: state.position!.longitude,
      dealType: dealType,
      categoryId: categoryId,
      sortBy: sortBy,
      limit: limit,
    );

    return response.success ? response.data : null;
  }
}

// Provider
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return LocationNotifier(locationService);
});
