// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService.instance;

  AuthNotifier() : super(AuthState.initial()) {
    _initializeAuth();
  }

  // ========== INITIALIZATION ==========

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      state = AuthState.loading();

      // Listen to Firebase Auth state changes
      _authService.authStateChanges.listen(_onAuthStateChanged);

      // Check if user is already signed in
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        state = AuthState.authenticated(currentUser);
      } else {
        final isFirstTime = StorageService.isFirstTimeUser();
        state = AuthState.unauthenticated(isFirstTime: isFirstTime);
      }
    } catch (e) {
      print('Error initializing auth: $e');
      state = AuthState.error('Failed to initialize authentication');
    }
  }

  /// Handle Firebase Auth state changes
  void _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        // User is signed in
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          // Firebase user exists but no profile found
          state = AuthState.unauthenticated();
        }
      } else {
        // User is signed out
        final isFirstTime = StorageService.isFirstTimeUser();
        state = AuthState.unauthenticated(isFirstTime: isFirstTime);
      }
    } catch (e) {
      print('Error handling auth state change: $e');
      state = AuthState.error('Authentication state error');
    }
  }

  // ========== EMAIL AUTHENTICATION ==========

  /// Register with email and password
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      state = AuthState.loading();

      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      state = AuthState.authenticated(user);
    } catch (e) {
      print('Registration error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = AuthState.loading();

      final user = await _authService.signInWithEmail(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      print('Sign in error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  // ========== GOOGLE AUTHENTICATION ==========

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = AuthState.loading();

      final user = await _authService.signInWithGoogle();
      state = AuthState.authenticated(user);
    } catch (e) {
      print('Google sign in error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  // ========== PASSWORD RESET ==========

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = AuthState.loading();

      await _authService.sendPasswordResetEmail(email);

      // Return to previous state but show success
      final isFirstTime = StorageService.isFirstTimeUser();
      state = AuthState.unauthenticated(isFirstTime: isFirstTime);
    } catch (e) {
      print('Password reset error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  // ========== EMAIL VERIFICATION ==========

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      print('Email verification error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  /// Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      return await _authService.isEmailVerified();
    } catch (e) {
      print('Check email verification error: $e');
      return false;
    }
  }

  // ========== USER PROFILE MANAGEMENT ==========

  /// Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      final user = await _authService.updateUserProfile(updatedUser);
      state = AuthState.authenticated(user);
    } catch (e) {
      print('Update profile error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        await signOut();
      }
    } catch (e) {
      print('Refresh user error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  // ========== SIGN OUT ==========

  /// Sign out user
  Future<void> signOut() async {
    try {
      state = AuthState.loading();

      await _authService.signOut();

      final isFirstTime = StorageService.isFirstTimeUser();
      state = AuthState.unauthenticated(isFirstTime: isFirstTime);
    } catch (e) {
      print('Sign out error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  // ========== ACCOUNT MANAGEMENT ==========

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      state = AuthState.loading();

      await _authService.deleteAccount();

      final isFirstTime = StorageService.isFirstTimeUser();
      state = AuthState.unauthenticated(isFirstTime: isFirstTime);
    } catch (e) {
      print('Delete account error: $e');
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  // ========== STATE MANAGEMENT ==========

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      final isFirstTime = StorageService.isFirstTimeUser();
      state = AuthState.unauthenticated(isFirstTime: isFirstTime);
    }
  }

  /// Reset to initial state
  void reset() {
    state = AuthState.initial();
  }

  // ========== UTILITY METHODS ==========

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// Get current user from state
  UserModel? get currentUser => state.user;

  /// Check if user is authenticated
  bool get isAuthenticated => state.isAuthenticated;

  /// Check if authentication is loading
  bool get isLoading => state.isLoading;

  /// Get current error message
  String? get errorMessage => state.errorMessage;
}

// ========== ADDITIONAL PROVIDERS ==========

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Provider to get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Provider to check if auth is loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading;
});

/// Provider to get auth error
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.errorMessage;
});

/// Provider to check if user email is verified
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.emailVerified ?? false;
});

/// Provider to check if user has complete profile
final hasCompleteProfileProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.hasCompleteProfile ?? false;
});

/// Provider for user display name
final userDisplayNameProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.displayName ?? 'User';
});

/// Provider for user initials
final userInitialsProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.initials ?? 'U';
});

// ========== AUTH GUARD PROVIDER ==========

/// Provider to determine navigation route based on auth state
final authRouteProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  final isFirstTime = StorageService.isFirstTimeUser();

  if (authState.isAuthenticated) {
    return '/home';
  } else if (authState.isUnauthenticated) {
    if (isFirstTime) {
      return '/onboarding';
    } else {
      return '/auth/login';
    }
  } else {
    return '/splash';
  }
});

// ========== STREAM PROVIDERS ==========

/// Provider for Firebase Auth state stream
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return AuthService.instance.authStateChanges;
});

// ========== FAMILY PROVIDERS ==========

/// Provider to check specific permissions
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user == null) return false;

  switch (permission) {
    case 'email_verified':
      return user.emailVerified;
    case 'complete_profile':
      return user.hasCompleteProfile;
    case 'has_phone':
      return user.phone?.isNotEmpty == true;
    case 'has_address':
      return user.address?.isNotEmpty == true;
    default:
      return false;
  }
});

// ========== COMPUTED PROVIDERS ==========

/// Provider for user's formatted address
final userAddressProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.formattedAddress ?? 'No address provided';
});

/// Provider for user's membership duration
final membershipDurationProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user == null) return '';

  final now = DateTime.now();
  final difference = now.difference(user.createdAt);

  if (difference.inDays < 30) {
    return 'Member for ${difference.inDays} days';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return 'Member for $months months';
  } else {
    final years = (difference.inDays / 365).floor();
    return 'Member for $years years';
  }
});

// ========== ASYNC PROVIDERS ==========

/// Provider for user's saved preferences (async)
final userPreferencesProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return {};

  // Get user preferences from storage or API
  return await StorageService.getAppPreferences();
});

/// Provider for user's notification settings (async)
final userNotificationSettingsProvider =
    FutureProvider<Map<String, bool>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return {};

  return await StorageService.getNotificationSettings();
});
