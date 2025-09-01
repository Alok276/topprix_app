// lib/features/subscription/widgets/subscription_success_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topprix/features/home/retailer_home/subscription/subscription_model.dart';
import 'package:topprix/theme/app_theme.dart';

class SubscriptionSuccessDialog extends StatelessWidget {
  final CreateSubscriptionResponse response;
  final VoidCallback onPaymentPressed;
  final VoidCallback onClosePressed;

  const SubscriptionSuccessDialog({
    super.key,
    required this.response,
    required this.onPaymentPressed,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              'Subscription Created!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              response.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Subscription details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Plan', response.subscription.pricingPlan?.name ?? 'N/A'),
                  _buildDetailRow('Status', response.subscription.statusText),
                  _buildDetailRow('Subscription ID', response.subscriptionId,
                      copyable: true),
                  if (response.subscription.pricingPlan != null)
                    _buildDetailRow('Price',
                        '${response.subscription.pricingPlan!.formattedPrice} ${response.subscription.pricingPlan!.intervalText}'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.payment,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete Your Payment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    response.paymentInstructions,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Column(
              children: [
                // Payment button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onPaymentPressed,
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Complete Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Secondary actions row
                Row(
                  children: [
                    // Download invoice button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadInvoice(context),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text(
                          'Invoice',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Close button
                    Expanded(
                      child: TextButton(
                        onPressed: onClosePressed,
                        child: const Text(
                          'Close',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (copyable)
                  GestureDetector(
                    onTap: () => _copyToClipboard(value),
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _downloadInvoice(BuildContext context) {
    // In a real app, you might want to download the PDF or open it in a browser
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice download feature coming soon!'),
      ),
    );
  }
}
