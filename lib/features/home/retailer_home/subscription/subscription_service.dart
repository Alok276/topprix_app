// lib/features/subscription/services/subscription_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/home/retailer_home/subscription/subscription_model.dart';
import 'package:topprix/core/provider/dio_provider.dart';

class SubscriptionService {
  final Dio _dio;

  SubscriptionService(this._dio);

  // Get all pricing plans
  Future<List<PricingPlan>> getPricingPlans({bool activeOnly = true}) async {
    try {
      final queryParams = activeOnly ? {'active': 'true'} : <String, dynamic>{};

      final response = await _dio.get(
        '/api/pricing-plans',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> plansJson = response.data['pricingPlans'] ?? [];
        return plansJson.map((json) => PricingPlan.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching pricing plans: $e');
      rethrow;
    }
  }

  // Create a new subscription
  Future<CreateSubscriptionResponse> createSubscription({
    required String userId,
    required String pricingPlanId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/subscriptions',
        data: {
          'userId': userId,
          'pricingPlanId': pricingPlanId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateSubscriptionResponse.fromJson(response.data);
      }
      throw Exception('Failed to create subscription');
    } catch (e) {
      print('Error creating subscription: $e');
      rethrow;
    }
  }

  // Get user's current subscription
  Future<Subscription?> getUserSubscription(String userId) async {
    try {
      final response = await _dio.get('/api/users/$userId/subscription');

      if (response.statusCode == 200) {
        final subscriptionData = response.data['subscription'];
        if (subscriptionData != null) {
          return Subscription.fromJson(subscriptionData);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user subscription: $e');
      return null;
    }
  }

  // Update subscription to a different plan
  Future<Subscription> updateSubscription({
    required String userId,
    required String newPricingPlanId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/subscriptions',
        data: {
          'userId': userId,
          'newPricingPlanId': newPricingPlanId,
        },
      );

      if (response.statusCode == 200) {
        return Subscription.fromJson(response.data['subscription']);
      }
      throw Exception('Failed to update subscription');
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription({
    required String userId,
    bool atPeriodEnd = true,
  }) async {
    try {
      final response = await _dio.post(
        '/api/subscriptions/cancel',
        data: {
          'userId': userId,
          'atPeriodEnd': atPeriodEnd,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error canceling subscription: $e');
      rethrow;
    }
  }

  // Complete checkout session (after Stripe payment)
  Future<Subscription> completeCheckout(String sessionId) async {
    try {
      final response = await _dio.post(
        '/api/subscriptions/checkout/complete',
        data: {'sessionId': sessionId},
      );

      if (response.statusCode == 200) {
        return Subscription.fromJson(response.data['subscription']);
      }
      throw Exception('Failed to complete checkout');
    } catch (e) {
      print('Error completing checkout: $e');
      rethrow;
    }
  }
}

// Providers
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final dio = ref.read(dioProvider);
  return SubscriptionService(dio);
});

// Pricing plans provider
final pricingPlansProvider = FutureProvider<List<PricingPlan>>((ref) async {
  final service = ref.read(subscriptionServiceProvider);
  return service.getPricingPlans();
});

// User subscription provider
final userSubscriptionProvider =
    FutureProvider.family<Subscription?, String>((ref, userId) async {
  final service = ref.read(subscriptionServiceProvider);
  return service.getUserSubscription(userId);
});

// Subscription state notifier for managing subscription operations
class SubscriptionState {
  final bool isLoading;
  final String? error;
  final CreateSubscriptionResponse? subscriptionResponse;
  final List<PricingPlan> pricingPlans;
  final Subscription? currentSubscription;

  const SubscriptionState({
    this.isLoading = false,
    this.error,
    this.subscriptionResponse,
    this.pricingPlans = const [],
    this.currentSubscription,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    String? error,
    CreateSubscriptionResponse? subscriptionResponse,
    List<PricingPlan>? pricingPlans,
    Subscription? currentSubscription,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      subscriptionResponse: subscriptionResponse ?? this.subscriptionResponse,
      pricingPlans: pricingPlans ?? this.pricingPlans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(const SubscriptionState());

  Future<void> loadPricingPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plans = await _service.getPricingPlans();
      state = state.copyWith(
        isLoading: false,
        pricingPlans: plans,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createSubscription({
    required String userId,
    required String pricingPlanId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.createSubscription(
        userId: userId,
        pricingPlanId: pricingPlanId,
      );
      state = state.copyWith(
        isLoading: false,
        subscriptionResponse: response,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUserSubscription(String userId) async {
    try {
      final subscription = await _service.getUserSubscription(userId);
      state = state.copyWith(currentSubscription: subscription);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSubscriptionResponse() {
    state = state.copyWith(subscriptionResponse: null);
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final service = ref.read(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});
