import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

// Coupon State
class CouponState {
  final List<CouponModel> coupons;
  final List<CouponModel> savedCoupons;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  CouponState({
    this.coupons = const [],
    this.savedCoupons = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  CouponState copyWith({
    List<CouponModel>? coupons,
    List<CouponModel>? savedCoupons,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return CouponState(
      coupons: coupons ?? this.coupons,
      savedCoupons: savedCoupons ?? this.savedCoupons,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Coupon Notifier
class CouponNotifier extends StateNotifier<CouponState> {
  final CouponService _couponService;

  CouponNotifier(this._couponService) : super(CouponState());

  Future<void> loadCoupons({
    bool refresh = false,
    String? storeId,
    String? categoryId,
  }) async {
    if (refresh) {
      state = state.copyWith(
        coupons: [],
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

    final response = await _couponService.getActiveCoupons(
      storeId: storeId,
      categoryId: categoryId,
      page: refresh ? 1 : state.currentPage,
    );

    if (response.success && response.data != null) {
      final newCoupons = response.data!;

      state = state.copyWith(
        coupons: refresh ? newCoupons : [...state.coupons, ...newCoupons],
        isLoading: false,
        hasMore: newCoupons.length >= 20,
        currentPage: refresh ? 2 : state.currentPage + 1,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load coupons',
        isLoading: false,
      );
    }
  }

  Future<void> loadSavedCoupons(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _couponService.getUserSavedCoupons(userId);

    if (response.success && response.data != null) {
      state = state.copyWith(
        savedCoupons: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load saved coupons',
        isLoading: false,
      );
    }
  }

  Future<bool> saveCoupon(String couponId) async {
    final response = await _couponService.saveCoupon(couponId);

    if (response.success) {
      // Update the coupon in the list to show it's saved
      final updatedCoupons = state.coupons.map((coupon) {
        if (coupon.id == couponId) {
          return coupon.copyWith(isSaved: true);
        }
        return coupon;
      }).toList();

      state = state.copyWith(coupons: updatedCoupons);
      return true;
    }

    return false;
  }

  Future<bool> unsaveCoupon(String couponId) async {
    final response = await _couponService.unsaveCoupon(couponId);

    if (response.success) {
      // Update the coupon in the list to show it's not saved
      final updatedCoupons = state.coupons.map((coupon) {
        if (coupon.id == couponId) {
          return coupon.copyWith(isSaved: false);
        }
        return coupon;
      }).toList();

      // Remove from saved coupons
      final updatedSavedCoupons =
          state.savedCoupons.where((coupon) => coupon.id != couponId).toList();

      state = state.copyWith(
        coupons: updatedCoupons,
        savedCoupons: updatedSavedCoupons,
      );
      return true;
    }

    return false;
  }

  Future<void> searchCoupons(String query) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _couponService.searchCoupons(query);

    if (response.success && response.data != null) {
      state = state.copyWith(
        coupons: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to search coupons',
        isLoading: false,
      );
    }
  }
}

// Provider
final couponProvider =
    StateNotifierProvider<CouponNotifier, CouponState>((ref) {
  final couponService = ref.watch(couponServiceProvider);
  return CouponNotifier(couponService);
});

// Individual Coupon Provider
final couponDetailProvider =
    FutureProvider.family<CouponModel?, String>((ref, couponId) async {
  final couponService = ref.watch(couponServiceProvider);
  final response = await couponService.getCouponDetail(couponId);
  return response.success ? response.data : null;
});
