// lib/ui/Auths/splash_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:topprix/provider/app_state.dart';
import '../../provider/auth_provider.dart';
import '../../models/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationAndNavigation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
  }

  void _startAnimationAndNavigation() async {
    // Start animation
    _animationController.forward();

    // Wait for minimum splash duration (for branding)
    await Future.delayed(const Duration(seconds: 2));

    // Navigate when both animation and state loading are complete
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    if (_hasNavigated || !mounted) return;

    final appState = ref.read(appStateProvider);
    final authState = ref.read(authProvider);

    // Don't navigate if still loading
    if (appState.isLoading || authState.isLoading) {
      return;
    }

    _hasNavigated = true;

    // Determine next route based on state
    final nextRoute = ref.read(nextRouteProvider);

    print('🚀 Navigating to: $nextRoute');
    print(
        '📊 App State - FirstTime: ${appState.isFirstTime}, Onboarding: ${appState.onboardingCompleted}');
    print(
        '🔐 Auth State - Status: ${authState.status}, User: ${authState.user?.email}');

    context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes for navigation
    ref.listen<AppState>(appStateProvider, (previous, next) {
      if (!next.isLoading && !_hasNavigated) {
        _checkAndNavigate();
      }
    });

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isLoading && !_hasNavigated) {
        _checkAndNavigate();
      }
    });

    final appState = ref.watch(appStateProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_offer,
                          size: 60,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'TopPrix',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Best Deals, Every Day',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getLoadingText(appState, authState),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLoadingText(AppState appState, AuthState authState) {
    if (appState.hasError || authState.hasError) {
      return 'Error loading app...';
    }

    if (appState.isLoading) {
      return 'Initializing app...';
    }

    if (authState.isLoading) {
      return 'Checking authentication...';
    }

    return 'Loading...';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
