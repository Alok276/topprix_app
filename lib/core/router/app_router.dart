// lib/core/router/app_router.dart - Updated with new pages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:topprix/provider/auth_provider.dart';
import 'package:topprix/ui/pages/home/home_dashboard.dart';
import '../../ui/Auths/splash_screen.dart';
import '../../ui/Auths/onboarding_screen.dart';
import '../../ui/Auths/login_screen.dart';
import '../../ui/Auths/email_login_screen.dart';
import '../../ui/Auths/register_screen.dart';
import '../../ui/Auths/forgot_password_screen.dart';
import '../../ui/Auths/home_screen.dart';
import '../../ui/pages/search/search_results_page.dart';
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

    // Placeholder routes for navigation (you'll create these pages later)
    GoRoute(
      path: '/flyers',
      name: 'flyers',
      builder: (context, state) => const PlaceholderPage(title: 'Flyers'),
    ),
    GoRoute(
      path: '/coupons',
      name: 'coupons',
      builder: (context, state) => const PlaceholderPage(title: 'Coupons'),
    ),
    GoRoute(
      path: '/stores',
      name: 'stores',
      builder: (context, state) => const PlaceholderPage(title: 'Stores'),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const PlaceholderPage(title: 'Profile'),
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const PlaceholderPage(title: 'Categories'),
    ),
    GoRoute(
      path: '/category/:categoryName',
      name: 'category-detail',
      builder: (context, state) {
        final categoryName = state.pathParameters['categoryName'] ?? '';
        return PlaceholderPage(title: 'Category: $categoryName');
      },
    ),
    GoRoute(
      path: '/nearby-deals',
      name: 'nearby-deals',
      builder: (context, state) => const PlaceholderPage(title: 'Nearby Deals'),
    ),
    GoRoute(
      path: '/qr-scanner',
      name: 'qr-scanner',
      builder: (context, state) => const PlaceholderPage(title: 'QR Scanner'),
    ),
    GoRoute(
      path: '/shopping-list',
      name: 'shopping-list',
      builder: (context, state) =>
          const PlaceholderPage(title: 'Shopping List'),
    ),

    // Error Route
    GoRoute(
      path: '/error',
      name: 'error',
      builder: (context, state) {
        final message = state.uri.queryParameters['message'] ?? 'Unknown error';
        return _buildErrorPage(context, state, message);
      },
    ),
  ];
}

// ========== ERROR PAGE ==========
Widget _buildErrorPage(BuildContext context, GoRouterState state,
    [String? error]) {
  return Scaffold(
    body: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 96,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
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
  );
}

// ========== PLACEHOLDER PAGE ==========
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
