// lib/features/subscription/models/pricing_plan.dart
class PricingPlan {
  final String id;
  final String name;
  final String description;
  final double amount;
  final String currency;
  final String interval; // 'month', 'year', etc.
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PricingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.features,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'eur',
      interval: json['interval'] ?? 'month',
      features: List<String>.from(json['features'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'currency': currency,
      'interval': interval,
      'features': features,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice {
    final currencySymbol = currency.toUpperCase() == 'EUR' ? '€' : '\$';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String get intervalText {
    switch (interval.toLowerCase()) {
      case 'month':
        return 'per month';
      case 'year':
        return 'per year';
      default:
        return 'per $interval';
    }
  }
}

// lib/features/subscription/models/subscription.dart
enum SubscriptionStatus {
  active,
  inactive,
  pastDue,
  canceled,
  unpaid,
  trialing,
}

class Subscription {
  final String id;
  final String userId;
  final String pricingPlanId;
  final SubscriptionStatus status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String? stripeSubscriptionId;
  final PricingPlan? pricingPlan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.pricingPlanId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.stripeSubscriptionId,
    this.pricingPlan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      pricingPlanId: json['pricingPlanId'] ?? '',
      status: _parseStatus(json['status']),
      currentPeriodStart: DateTime.parse(
          json['currentPeriodStart'] ?? DateTime.now().toIso8601String()),
      currentPeriodEnd: DateTime.parse(
          json['currentPeriodEnd'] ?? DateTime.now().toIso8601String()),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
      stripeSubscriptionId: json['stripeSubscriptionId'],
      pricingPlan: json['pricingPlan'] != null
          ? PricingPlan.fromJson(json['pricingPlan'])
          : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static SubscriptionStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return SubscriptionStatus.active;
      case 'INACTIVE':
        return SubscriptionStatus.inactive;
      case 'PAST_DUE':
        return SubscriptionStatus.pastDue;
      case 'CANCELED':
        return SubscriptionStatus.canceled;
      case 'UNPAID':
        return SubscriptionStatus.unpaid;
      case 'TRIALING':
        return SubscriptionStatus.trialing;
      default:
        return SubscriptionStatus.inactive;
    }
  }

  String get statusText {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.inactive:
        return 'Inactive';
      case SubscriptionStatus.pastDue:
        return 'Past Due';
      case SubscriptionStatus.canceled:
        return 'Canceled';
      case SubscriptionStatus.unpaid:
        return 'Unpaid';
      case SubscriptionStatus.trialing:
        return 'Trial';
    }
  }

  bool get isActive => status == SubscriptionStatus.active;
}

// lib/features/subscription/models/subscription_response.dart
class CreateSubscriptionResponse {
  final String message;
  final String subscriptionId;
  final String hostedInvoiceUrl;
  final String invoicePdfUrl;
  final Subscription subscription;
  final String paymentInstructions;

  CreateSubscriptionResponse({
    required this.message,
    required this.subscriptionId,
    required this.hostedInvoiceUrl,
    required this.invoicePdfUrl,
    required this.subscription,
    required this.paymentInstructions,
  });

  factory CreateSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionResponse(
      message: json['message'] ?? '',
      subscriptionId: json['subscriptionId'] ?? '',
      hostedInvoiceUrl: json['hostedInvoiceUrl'] ?? '',
      invoicePdfUrl: json['invoicePdfUrl'] ?? '',
      subscription: Subscription.fromJson(json['subscription'] ?? {}),
      paymentInstructions: json['paymentInstructions'] ?? '',
    );
  }
}
