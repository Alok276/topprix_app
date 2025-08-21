enum AuthStatus { authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? role; // "user" or "retailer"

  AuthState({required this.status, this.token, this.role});

  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(String token, String role) =>
      AuthState(status: AuthStatus.authenticated, token: token, role: role);
  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated);
}
