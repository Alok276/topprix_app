// lib/core/router/app_router.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:topprix/provider/app_state.dart';
import '../../provider/auth_provider.dart';
import '../../ui/Auths/splash_screen.dart';
import '../../ui/Auths/onboarding_screen.dart';
import '../../ui/Auths/login_screen.dart';
import '../../ui/Auths/email_login_screen.dart';
import '../../ui/Auths/register_screen.dart';
import '../../ui/Auths/forgot_password_screen.dart';
import '../../ui/pages/home/home_dashboard.dart';
import '../../ui/pages/search/search_results_page.dart';
import '../../models/auth_state.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final appState = ref.watch(appStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) =>
        _handleRedirect(context, state, authState, appState),
    routes: _buildRoutes(),
    errorBuilder: (context, state) => _buildErrorPage(context, state),
  );
});

// ========== REDIRECT LOGIC ==========
String? _handleRedirect(
  BuildContext context,
  GoRouterState state,
  AuthState authState,
  AppState appState,
) {
  final currentLocation = state.uri.toString();

  // Don't redirect during loading or on error pages
  if (currentLocation == '/splash' ||
      currentLocation.startsWith('/error') ||
      authState.isLoading ||
      appState.isLoading) {
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
    // Use the app state's isFirstTime which is loaded asynchronously
    final isFirstTime = appState.isFirstTime;

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

    // Onboarding
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Authentication Routes
    GoRoute(
      path: '/auth',
      name: 'auth',
      redirect: (context, state) => '/auth/login',
    ),
    GoRoute(
      path: '/auth/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/email-login',
      name: 'email-login',
      builder: (context, state) => const EmailLoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Main App Routes
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeDashboard(),
    ),

    // Search Results
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchResultsPage(query: query);
      },
    ),

    // Categories
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Categories Page - Coming Soon')),
      ),
    ),

    // Category Detail
    GoRoute(
      path: '/category/:categoryId',
      name: 'category-detail',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return Scaffold(
          body: Center(child: Text('Category: $categoryId - Coming Soon')),
        );
      },
    ),

    // Store Detail
    GoRoute(
      path: '/store/:storeId',
      name: 'store-detail',
      builder: (context, state) {
        final storeId = state.pathParameters['storeId']!;
        return Scaffold(
          body: Center(child: Text('Store: $storeId - Coming Soon')),
        );
      },
    ),

    // Deal Detail
    GoRoute(
      path: '/deal/:dealId',
      name: 'deal-detail',
      builder: (context, state) {
        final dealId = state.pathParameters['dealId']!;
        return Scaffold(
          body: Center(child: Text('Deal: $dealId - Coming Soon')),
        );
      },
    ),

    // Profile
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Profile Page - Coming Soon')),
      ),
    ),

    // Settings
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Settings Page - Coming Soon')),
      ),
    ),
  ];
}

// ========== ERROR PAGE ==========
Widget _buildErrorPage(BuildContext context, GoRouterState state) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Error'),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page Not Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The page "${state.uri}" could not be found.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  );
}
