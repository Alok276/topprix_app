// lib/models/auth_state.dart
import 'user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isFirstTime;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isFirstTime = false,
  });

  // Initial state
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      isFirstTime: true,
    );
  }

  // Loading state
  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
    );
  }

  // Authenticated state
  factory AuthState.authenticated(UserModel user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  // Unauthenticated state
  factory AuthState.unauthenticated({bool isFirstTime = false}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      isFirstTime: isFirstTime,
    );
  }

  // Error state
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  // Copy with new values
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isFirstTime,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  // Convenience getters
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && errorMessage != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isInitial => status == AuthStatus.initial;

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, error: $errorMessage, isFirstTime: $isFirstTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage &&
        other.isFirstTime == isFirstTime;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        user.hashCode ^
        errorMessage.hashCode ^
        isFirstTime.hashCode;
  }
}
