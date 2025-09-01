// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:topprix/features/home/retailer_home/flyer/flyer_models.dart';
// import 'package:topprix/features/home/retailer_home/flyer/services/stripe_payment_service.dart';\nimport 'package:topprix/theme/app_theme.dart';

// class PaymentDialog extends ConsumerWidget {
//   final CreateFlyerResponse flyerResponse;

//   const PaymentDialog({
//     super.key,
//     required this.flyerResponse,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       title: Row(
//         children: [
//           Icon(
//             Icons.payment,
//             color: Theme.of(context).primaryColor,
//             size: 28,
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               'Payment Required',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Flyer created success message
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppTheme.successColor[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppTheme.successColor[200]!),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: AppTheme.successColor[600],
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Flyer Created!',
//                         style: TextStyle(
//                           color: AppTheme.successColor[800],
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     flyerResponse.message,
//                     style: TextStyle(
//                       color: AppTheme.successColor[700],
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Payment amount
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryColor[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppTheme.primaryColor[300]!),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Flyer Upload Fee',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: AppTheme.primaryColor[800],
//                         ),
//                       ),
//                       Text(
//                         'One-time payment to activate your flyer',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppTheme.primaryColor[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     '€${flyerResponse.paymentAmount?.toStringAsFixed(2) ?? '9.99'}',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppTheme.primaryColor[800],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Payment instructions
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppTheme.secondaryColor[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: AppTheme.secondaryColor[300]!),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: AppTheme.secondaryColor[700],
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Your flyer is created but inactive until payment is completed. Click "Pay Now" to activate it.',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: AppTheme.secondaryColor[800],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop(false);
//           },
//           child: const Text(
//             'Cancel',
//             style: TextStyle(color: Colors.grey),
//           ),
//         ),
//         ElevatedButton.icon(
//           onPressed: () async {
//             // Close dialog first
//             Navigator.of(context).pop(true);

//             // Process payment with Stripe
//             await _processStripePayment(context, ref);
//           },
//           icon: const Icon(Icons.credit_card),
//           label: const Text('Pay Now'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Theme.of(context).primaryColor,
//             foregroundColor: AppTheme.surfaceColor,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _processStripePayment(
//       BuildContext context, WidgetRef ref) async {
//     try {
//       final stripeService = ref.read(stripePaymentServiceProvider);

//       final success = await stripeService.processPayment(
//         flyerId: flyerResponse.flyer.id,
//         amount: flyerResponse.paymentAmount ?? 9.99,
//         currency: flyerResponse.currency ?? 'eur',
//         context: context,
//       );

//       if (success && context.mounted) {
//         // Payment successful - show success dialog
//         _showPaymentSuccess(context);
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Payment error: $e'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//     }
//   }

//   void _showPaymentSuccess(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.check_circle,
//               color: AppTheme.successColor,
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Payment Successful!',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Your flyer is now active and visible to customers.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close success dialog
//                 Navigator.of(context).pop(); // Go back to flyer screen
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.successColor,
//                 foregroundColor: AppTheme.surfaceColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Great!'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
