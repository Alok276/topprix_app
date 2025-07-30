// lib/provider/app_state_provider.dart - NEW FILE
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/provider/auth_provider.dart';
import '../services/storage_service.dart';

// ========== APP STATE MODEL ==========

class AppState {
  final bool isLoading;
  final bool isFirstTime;
  final bool onboardingCompleted;
  final String? error;

  AppState({
    this.isLoading = false,
    this.isFirstTime = true,
    this.onboardingCompleted = false,
    this.error,
  });

  AppState copyWith({
    bool? isLoading,
    bool? isFirstTime,
    bool? onboardingCompleted,
    String? error,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      error: error ?? this.error,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get isReady => !isLoading && !hasError;
}

// ========== APP STATE NOTIFIER ==========

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load app state from storage
      final isFirstTime = await StorageService.isFirstTimeUser();
      final onboardingCompleted = await StorageService.isOnboardingCompleted();

      state = state.copyWith(
        isLoading: false,
        isFirstTime: isFirstTime,
        onboardingCompleted: onboardingCompleted,
      );

      print(
          '🏗️ App state initialized: firstTime=$isFirstTime, onboarding=$onboardingCompleted');
    } catch (e) {
      print('❌ Error initializing app state: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize app state',
      );
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      await StorageService.completeOnboarding();
      state = state.copyWith(
        isFirstTime: false,
        onboardingCompleted: true,
      );
      print('✅ Onboarding completed');
    } catch (e) {
      print('❌ Error completing onboarding: $e');
      state = state.copyWith(error: 'Failed to complete onboarding');
    }
  }

  /// Reset app state (for testing or logout)
  Future<void> resetAppState() async {
    try {
      state = state.copyWith(isLoading: true);

      // Clear storage (this will be handled by StorageService.clearUserData)
      await StorageService.clearUserData();

      // Reload state
      await _initialize();

      print('🔄 App state reset');
    } catch (e) {
      print('❌ Error resetting app state: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset app state',
      );
    }
  }

  /// Manually set first time user status
  void setFirstTimeUser(bool isFirstTime) {
    state = state.copyWith(isFirstTime: isFirstTime);
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh app state
  Future<void> refresh() async {
    await _initialize();
  }
}

// ========== PROVIDERS ==========

/// Main app state provider
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// Provider for checking if app is ready (not loading and no errors)
final appReadyProvider = Provider<bool>((ref) {
  final appState = ref.watch(appStateProvider);
  return appState.isReady;
});

/// Provider for first time user status
final isFirstTimeUserProvider = Provider<bool>((ref) {
  final appState = ref.watch(appStateProvider);
  return appState.isFirstTime;
});

/// Provider for onboarding completion status
final onboardingCompletedProvider = Provider<bool>((ref) {
  final appState = ref.watch(appStateProvider);
  return appState.onboardingCompleted;
});

/// Provider to determine if splash screen should be shown
final shouldShowSplashProvider = Provider<bool>((ref) {
  final appState = ref.watch(appStateProvider);
  return appState.isLoading;
});

/// Provider to determine next route after splash
final nextRouteProvider = Provider<String>((ref) {
  final appState = ref.watch(appStateProvider);
  final authState = ref.watch(authProvider);

  // If app is still loading, stay on splash
  if (appState.isLoading) {
    return '/splash';
  }

  // If user is authenticated, go to home
  if (authState.isAuthenticated) {
    return '/home';
  }

  // If first time user, go to onboarding
  if (appState.isFirstTime) {
    return '/onboarding';
  }

  // Otherwise, go to login
  return '/auth/login';
});
