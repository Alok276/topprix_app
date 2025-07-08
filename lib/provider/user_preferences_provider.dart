import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/services/api_service.dart';
import '../models/store_model.dart';
import '../models/category_model.dart';

// User Preferences State
class UserPreferencesState {
  final List<StoreModel> preferredStores;
  final List<CategoryModel> preferredCategories;
  final bool isLoading;
  final String? error;

  UserPreferencesState({
    this.preferredStores = const [],
    this.preferredCategories = const [],
    this.isLoading = false,
    this.error,
  });

  UserPreferencesState copyWith({
    List<StoreModel>? preferredStores,
    List<CategoryModel>? preferredCategories,
    bool? isLoading,
    String? error,
  }) {
    return UserPreferencesState(
      preferredStores: preferredStores ?? this.preferredStores,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// User Preferences Notifier
class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  final ApiService _apiService;

  UserPreferencesNotifier(this._apiService) : super(UserPreferencesState());

  Future<void> loadPreferences(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storesResponse = await _apiService.getPreferredStores(email);
      final categoriesResponse =
          await _apiService.getPreferredCategories(email);

      state = state.copyWith(
        preferredStores: storesResponse.success ? storesResponse.data! : [],
        preferredCategories:
            categoriesResponse.success ? categoriesResponse.data! : [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load preferences',
        isLoading: false,
      );
    }
  }

  Future<bool> addPreferredStore(String email, String storeId) async {
    final response = await _apiService.addPreferredStore(email, storeId);
    if (response.success) {
      await loadPreferences(email);
      return true;
    }
    return false;
  }

  Future<bool> removePreferredStore(String email, String storeId) async {
    final response = await _apiService.removePreferredStore(email, storeId);
    if (response.success) {
      await loadPreferences(email);
      return true;
    }
    return false;
  }

  Future<bool> addPreferredCategory(String email, String categoryId) async {
    final response = await _apiService.addPreferredCategory(email, categoryId);
    if (response.success) {
      await loadPreferences(email);
      return true;
    }
    return false;
  }

  Future<bool> removePreferredCategory(String email, String categoryId) async {
    final response =
        await _apiService.removePreferredCategory(email, categoryId);
    if (response.success) {
      await loadPreferences(email);
      return true;
    }
    return false;
  }
}

// Provider
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  return UserPreferencesNotifier(ApiService());
});
