// lib/features/profile/providers/edit_profile_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/backend_user_service.dart';
import 'package:topprix/features/auth/service/auth_service.dart';

// Edit Profile State
class EditProfileState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final Map<String, String> validationErrors;

  const EditProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.validationErrors = const {},
  });

  EditProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    Map<String, String>? validationErrors,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

// Edit Profile Notifier
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final BackendUserService _backendService;
  final Ref _ref;

  EditProfileNotifier(this._backendService, this._ref)
      : super(const EditProfileState());

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String location,
    File? profileImage,
  }) async {
    state = state.copyWith(
      isSaving: true,
      error: null,
      successMessage: null,
      validationErrors: {},
    );

    try {
      // Get current user email
      final authState = _ref.read(topPrixAuthProvider);
      if (!authState.isAuthenticated || authState.backendUser == null) {
        throw Exception('User not authenticated');
      }

      final userEmail = authState.backendUser!.email;

      // Validate data before sending
      final validationErrors = _backendService.validateUserData(
        name: name,
        phone: phone,
        location: location,
      );

      if (validationErrors.isNotEmpty) {
        state = state.copyWith(
          isSaving: false,
          validationErrors: validationErrors,
        );
        return false;
      }

      // Update profile in backend
      final response = await _backendService.updateUser(
        email: userEmail,
        name: name.trim().isEmpty ? null : name.trim(),
        phone: phone.trim().isEmpty ? null : phone.trim(),
        location: location.trim().isEmpty ? null : location.trim(),
      );

      if (response.success && response.data != null) {
        // Update the auth provider with new user data
        await _ref.read(topPrixAuthProvider.notifier).updateUserProfile(
              name: name.trim().isEmpty ? null : name.trim(),
              phone: phone.trim().isEmpty ? null : phone.trim(),
              location: location.trim().isEmpty ? null : location.trim(),
              profileImage: profileImage,
            );

        state = state.copyWith(
          isSaving: false,
          successMessage: 'Profile updated successfully!',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update profile: $e',
      );
      return false;
    }
  }

  // Refresh user profile data
  Future<void> refreshProfile() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final authState = _ref.read(topPrixAuthProvider);
      if (!authState.isAuthenticated || authState.backendUser == null) {
        throw Exception('User not authenticated');
      }

      final userEmail = authState.backendUser!.email;

      final response = await _backendService.getCurrentUserProfile(
        email: userEmail,
      );

      if (response.success && response.data != null) {
        // Update auth state with fresh data by updating the backend user in state
        final currentState = _ref.read(topPrixAuthProvider);
        _ref.read(topPrixAuthProvider.notifier).state = currentState.copyWith(
          backendUser: response.data,
        );

        state = state.copyWith(
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh profile: $e',
      );
    }
  }

  // Clear errors
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  // Clear validation errors
  void clearValidationErrors() {
    state = state.copyWith(validationErrors: {});
  }
}

// Provider for Edit Profile
final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  final backendService = ref.watch(backendUserServiceProvider);
  return EditProfileNotifier(backendService, ref);
});

// Provider for Backend User Service
final backendUserServiceProvider = Provider<BackendUserService>((ref) {
  return BackendUserService();
});

// Helper providers for form validation
final profileFormValidationProvider =
    Provider.family<Map<String, String>, Map<String, String>>((ref, formData) {
  final backendService = ref.watch(backendUserServiceProvider);
  return backendService.validateUserData(
    name: formData['name'],
    phone: formData['phone'],
    location: formData['location'],
  );
});
