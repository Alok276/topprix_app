// lib/features/subscription/pages/subscription_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/home/retailer_home/subscription/pricing_plan_widget.dart';
import 'package:topprix/features/home/retailer_home/subscription/subscription_model.dart';
import 'package:topprix/features/home/retailer_home/subscription/subscription_service.dart';
import 'package:topprix/features/home/retailer_home/subscription/subscription_success_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:topprix/features/auth/service/auth_service.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  PricingPlan? selectedPlan;

  @override
  void initState() {
    super.initState();
    // Load pricing plans when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionNotifierProvider.notifier).loadPricingPlans();

      // Load user's current subscription if authenticated
      final authState = ref.read(topPrixAuthProvider);
      if (authState.isAuthenticated && authState.backendUser != null) {
        ref
            .read(subscriptionNotifierProvider.notifier)
            .loadUserSubscription(authState.backendUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final authState = ref.watch(topPrixAuthProvider);

    // Listen to subscription response for success handling
    ref.listen<SubscriptionState>(subscriptionNotifierProvider,
        (previous, next) {
      if (next.subscriptionResponse != null &&
          previous?.subscriptionResponse == null) {
        // Show success dialog and launch payment URL
        _showSubscriptionSuccess(next.subscriptionResponse!);
      }

      if (next.error != null && previous?.error != next.error) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: subscriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscriptionState.pricingPlans.isEmpty
              ? _buildEmptyState()
              : _buildPricingContent(authState),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No pricing plans available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingContent(AuthState authState) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(),
          const SizedBox(height: 32),

          // Current subscription status (if any)
          if (subscriptionState.currentSubscription != null)
            _buildCurrentSubscription(subscriptionState.currentSubscription!),

          // Pricing plans grid
          _buildPricingPlans(subscriptionState.pricingPlans),

          const SizedBox(height: 32),

          // Purchase button
          if (selectedPlan != null && authState.isAuthenticated)
            _buildPurchaseButton(authState.backendUser!.id),

          // Login prompt if not authenticated
          if (!authState.isAuthenticated) _buildLoginPrompt(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upgrade to Premium',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the perfect plan for your retail business and unlock premium features.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildCurrentSubscription(subscription) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: subscription.isActive ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              subscription.isActive ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            subscription.isActive ? Icons.check_circle : Icons.warning,
            color: subscription.isActive ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan: ${subscription.pricingPlan?.name ?? 'Unknown'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Status: ${subscription.statusText}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (subscription.isActive)
                  Text(
                    'Expires: ${subscription.currentPeriodEnd.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingPlans(List<PricingPlan> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Plans',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            childAspectRatio:
                MediaQuery.of(context).size.width > 600 ? 1.2 : 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            final isSelected = selectedPlan?.id == plan.id;

            return PricingPlanCard(
              plan: plan,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  selectedPlan = isSelected ? null : plan;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(String userId) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: subscriptionState.isLoading
            ? null
            : () => _purchaseSubscription(userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: subscriptionState.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Subscribe to ${selectedPlan!.name} - ${selectedPlan!.formattedPrice} ${selectedPlan!.intervalText}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Please log in to purchase a subscription',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to login page or show login dialog
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseSubscription(String userId) async {
    if (selectedPlan == null) return;

    await ref.read(subscriptionNotifierProvider.notifier).createSubscription(
          userId: userId,
          pricingPlanId: selectedPlan!.id,
        );
  }

  void _showSubscriptionSuccess(subscriptionResponse) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubscriptionSuccessDialog(
        response: subscriptionResponse,
        onPaymentPressed: () async {
          // Launch Stripe hosted invoice URL
          if (await canLaunchUrl(
              Uri.parse(subscriptionResponse.hostedInvoiceUrl))) {
            await launchUrl(
              Uri.parse(subscriptionResponse.hostedInvoiceUrl),
              mode: LaunchMode.externalApplication,
            );
          }
        },
        onClosePressed: () {
          // Clear the response and close dialog
          ref
              .read(subscriptionNotifierProvider.notifier)
              .clearSubscriptionResponse();
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Go back to previous page
        },
      ),
    );
  }
}
