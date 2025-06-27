// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:topprix/provider/auth_provider.dart';
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/onboarding_screen.dart';
import '../../ui/screens/login_screen.dart';
import '../../ui/screens/email_login_screen.dart';
import '../../ui/screens/register_screen.dart';
import '../../ui/screens/forgot_password_screen.dart';
import '../../ui/screens/home_screen.dart';
import '../../services/storage_service.dart';
import '../../models/auth_state.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) => _handleRedirect(context, state, authState),
    routes: _buildRoutes(),
    errorBuilder: (context, state) => _buildErrorPage(context, state),
  );
});

// ========== REDIRECT LOGIC ==========

String? _handleRedirect(
    BuildContext context, GoRouterState state, AuthState authState) {
  final currentLocation = state.uri.toString();

  // Don't redirect during loading or on error pages
  if (currentLocation == '/splash' ||
      currentLocation.startsWith('/error') ||
      authState.isLoading) {
    return null;
  }

  // Handle authenticated users
  if (authState.isAuthenticated) {
    // Authenticated users should not access auth screens
    if (currentLocation.startsWith('/auth') ||
        currentLocation == '/onboarding') {
      return '/home';
    }
    return null; // Allow access to other screens
  }

  // Handle unauthenticated users
  if (authState.isUnauthenticated) {
    final isFirstTime = StorageService.isFirstTimeUser();

    // First-time users should see onboarding
    if (isFirstTime && !currentLocation.startsWith('/onboarding')) {
      return '/onboarding';
    }

    // Returning users should see login
    if (!isFirstTime &&
        !currentLocation.startsWith('/auth') &&
        currentLocation != '/onboarding') {
      return '/auth/login';
    }

    return null; // Allow access to auth screens
  }

  // For initial state, go to splash
  if (authState.isInitial && currentLocation != '/splash') {
    return '/splash';
  }

  return null; // No redirect needed
}

// ========== ROUTE DEFINITIONS ==========

List<RouteBase> _buildRoutes() {
  return [
    // Splash Screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding Screen
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Authentication Routes
    GoRoute(
      path: '/auth',
      redirect: (context, state) {
        // Redirect /auth to /auth/login
        if (state.uri.toString() == '/auth') {
          return '/auth/login';
        }
        return null;
      },
      routes: [
        // Login Screen
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const LoginScreen(),
          ),
        ),

        // Email Login Screen
        GoRoute(
          path: '/email-login',
          name: 'email-login',
          builder: (context, state) => const EmailLoginScreen(),
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const EmailLoginScreen(),
          ),
        ),

        // Register Screen
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const RegisterScreen(),
          ),
        ),

        // Forgot Password Screen
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const ForgotPasswordScreen(),
          ),
        ),
      ],
    ),

    // Main App Routes (Protected)
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const HomeScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),

    // Profile Routes
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Profile Screen - Coming Soon'),
        ),
      ),
    ),

    // Deals Routes
    GoRoute(
      path: '/deals',
      name: 'deals',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Deals Screen - Coming Soon'),
        ),
      ),
    ),

    // Stores Routes
    GoRoute(
      path: '/stores',
      name: 'stores',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Stores Screen - Coming Soon'),
        ),
      ),
    ),

    // Search Routes
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return Scaffold(
          appBar: AppBar(title: Text('Search: $query')),
          body: const Center(
            child: Text('Search Screen - Coming Soon'),
          ),
        );
      },
    ),

    // Settings Routes
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Settings Screen - Coming Soon'),
        ),
      ),
    ),

    // Error Route
    GoRoute(
      path: '/error',
      name: 'error',
      builder: (context, state) {
        final error = state.uri.queryParameters['message'] ?? 'Unknown error';
        return _buildErrorPage(context, state, error);
      },
    ),
  ];
}

// ========== PAGE TRANSITIONS ==========

enum PageTransitionType {
  slide,
  fade,
  scale,
  rotation,
}

Page<dynamic> _buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  PageTransitionType transitionType = PageTransitionType.slide,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case PageTransitionType.slide:
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );

        case PageTransitionType.fade:
          return FadeTransition(
            opacity: animation.drive(
              CurveTween(curve: Curves.easeInOut),
            ),
            child: child,
          );

        case PageTransitionType.scale:
          return ScaleTransition(
            scale: animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );

        case PageTransitionType.rotation:
          return RotationTransition(
            turns: animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );
      }
    },
  );
}

// ========== ERROR PAGE ==========

Widget _buildErrorPage(BuildContext context, GoRouterState state,
    [String? error]) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Error'),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Page not found or an error occurred.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ========== NAVIGATION EXTENSIONS ==========

extension GoRouterExtensions on GoRouter {
  /// Navigate to home with optional data
  void goHome({Map<String, String>? extra}) {
    go('/home', extra: extra);
  }

  /// Navigate to login
  void goLogin() {
    go('/auth/login');
  }

  /// Navigate to register
  void goRegister() {
    go('/auth/register');
  }

  /// Navigate to profile
  void goProfile() {
    go('/profile');
  }

  /// Navigate to search with query
  void goSearch(String query) {
    go('/search?q=${Uri.encodeComponent(query)}');
  }

  /// Navigate to error page with message
  void goError(String message) {
    go('/error?message=${Uri.encodeComponent(message)}');
  }
}

// ========== CONTEXT EXTENSIONS ==========

extension BuildContextExtensions on BuildContext {
  /// Get the current route name
  String? get routeName {
    final route = GoRouterState.of(this);
    return route.name;
  }

  /// Get the current route path
  String get routePath {
    final route = GoRouterState.of(this);
    return route.uri.toString();
  }

  /// Check if current route matches
  bool isRoute(String routeName) {
    return this.routeName == routeName;
  }

  /// Check if current path starts with
  bool isPathStartsWith(String path) {
    return routePath.startsWith(path);
  }

  /// Navigate with animation type
  void goWithTransition(
    String path, {
    PageTransitionType transition = PageTransitionType.slide,
    Object? extra,
  }) {
    go(path, extra: extra);
  }

  /// Push with animation type
  void pushWithTransition(
    String path, {
    PageTransitionType transition = PageTransitionType.slide,
    Object? extra,
  }) {
    push(path, extra: extra);
  }
}

// ========== ROUTE GUARDS ==========

class RouteGuard {
  static String? requireAuth(BuildContext context, GoRouterState state) {
    // This can be used as a redirect function for protected routes
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authProvider);

    if (!authState.isAuthenticated) {
      return '/auth/login';
    }

    return null; // Allow access
  }

  static String? requireUnauth(BuildContext context, GoRouterState state) {
    // This can be used for auth-only routes (login, register, etc.)
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authProvider);

    if (authState.isAuthenticated) {
      return '/home';
    }

    return null; // Allow access
  }

  static String? requireEmailVerification(
      BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authProvider);

    if (!authState.isAuthenticated) {
      return '/auth/login';
    }

    if (authState.user?.emailVerified != true) {
      return '/auth/verify-email';
    }

    return null; // Allow access
  }

  static String? requireCompleteProfile(
      BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authProvider);

    if (!authState.isAuthenticated) {
      return '/auth/login';
    }

    if (authState.user?.hasCompleteProfile != true) {
      return '/profile/complete';
    }

    return null; // Allow access
  }
}

// ========== ROUTE INFORMATION ==========

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String emailLogin = '/auth/email-login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String deals = '/deals';
  static const String stores = '/stores';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String error = '/error';

  static List<String> get authRoutes => [
        login,
        emailLogin,
        register,
        forgotPassword,
      ];

  static List<String> get protectedRoutes => [
        home,
        profile,
        deals,
        stores,
        settings,
      ];

  static List<String> get publicRoutes => [
        splash,
        onboarding,
        error,
      ];
}
