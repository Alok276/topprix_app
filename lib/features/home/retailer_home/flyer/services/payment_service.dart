// lib/features/flyers/services/payment_service.dart
import 'package:dio/dio.dart';

// Payment Intent Model
class PaymentIntent {
  final String clientSecret;
  final String paymentIntentId;

  PaymentIntent({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      clientSecret: json['clientSecret'] ?? '',
      paymentIntentId: json['paymentIntentId'] ?? '',
    );
  }
}

// Create Payment Intent Request
class CreatePaymentIntentRequest {
  final String userId;
  final double amount;
  final String currency;
  final String paymentType;
  final String? flyerId;
  final String? couponId;

  CreatePaymentIntentRequest({
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentType,
    this.flyerId,
    this.couponId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'paymentType': paymentType,
      if (flyerId != null) 'flyerId': flyerId,
      if (couponId != null) 'couponId': couponId,
    };
  }
}

// Payment Success Request
class PaymentSuccessRequest {
  final String paymentIntentId;

  PaymentSuccessRequest({
    required this.paymentIntentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentIntentId': paymentIntentId,
    };
  }
}

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  /// Create payment intent for flyer upload
  Future<PaymentIntent?> createPaymentIntent(
      CreatePaymentIntentRequest request) async {
    try {
      print('💳 Creating payment intent: ${request.toJson()}');

      final response = await _dio.post(
        '/api/payment-intents',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Payment intent created successfully');
        return PaymentIntent.fromJson(response.data);
      }

      print('❌ Failed to create payment intent: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error creating payment intent: $e');
      if (e is DioException) {
        print('❌ Response data: ${e.response?.data}');
      }
      return null;
    }
  }

  /// Handle payment success
  Future<bool> handlePaymentSuccess(PaymentSuccessRequest request) async {
    try {
      print('✅ Processing payment success: ${request.toJson()}');

      final response = await _dio.post(
        '/api/payment-success',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ Payment success processed');
        return true;
      }

      print('❌ Failed to process payment success: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error processing payment success: $e');
      return false;
    }
  }

  /// Create payment intent specifically for flyer upload
  Future<PaymentIntent?> createFlyerPaymentIntent({
    required String userId,
    required String flyerId,
    required double amount,
    String currency = 'eur',
  }) async {
    return createPaymentIntent(
      CreatePaymentIntentRequest(
        userId: userId,
        amount: amount,
        currency: currency,
        paymentType: 'FLYER_UPLOAD',
        flyerId: flyerId,
      ),
    );
  }

  /// Create payment intent for coupon upload
  Future<PaymentIntent?> createCouponPaymentIntent({
    required String userId,
    required String couponId,
    required double amount,
    String currency = 'eur',
  }) async {
    return createPaymentIntent(
      CreatePaymentIntentRequest(
        userId: userId,
        amount: amount,
        currency: currency,
        paymentType: 'COUPON_UPLOAD',
        couponId: couponId,
      ),
    );
  }

  /// Get payment history for user
  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      print('📋 Getting payment history for user: $userId');

      final response = await _dio.get('/api/payments/history/$userId');

      if (response.statusCode == 200) {
        print('✅ Payment history retrieved');
        return List<Map<String, dynamic>>.from(response.data['payments'] ?? []);
      }

      print('❌ Failed to get payment history: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error getting payment history: $e');
      return [];
    }
  }

  /// Get payment status
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentIntentId) async {
    try {
      print('🔍 Getting payment status: $paymentIntentId');

      final response = await _dio.get('/api/payments/status/$paymentIntentId');

      if (response.statusCode == 200) {
        print('✅ Payment status retrieved');
        return response.data;
      }

      print('❌ Failed to get payment status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error getting payment status: $e');
      return null;
    }
  }

  /// Cancel payment intent
  Future<bool> cancelPaymentIntent(String paymentIntentId) async {
    try {
      print('❌ Canceling payment intent: $paymentIntentId');

      final response = await _dio.post('/api/payments/cancel/$paymentIntentId');

      if (response.statusCode == 200) {
        print('✅ Payment intent canceled');
        return true;
      }

      print('❌ Failed to cancel payment intent: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error canceling payment intent: $e');
      return false;
    }
  }

  void dispose() {
    _dio.close();
  }
}
