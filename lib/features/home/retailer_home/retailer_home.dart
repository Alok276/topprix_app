import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';
import 'package:topprix/features/auth/ui/login_page.dart';

class RetailerHome extends ConsumerStatefulWidget {
  const RetailerHome({super.key});

  @override
  ConsumerState<RetailerHome> createState() => _RetailerHomeState();
}

class _RetailerHomeState extends ConsumerState<RetailerHome> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          handleSignOut(ref: ref, context: context);
        },
        child: const Text('Retailer Home'),
      ),
    );
  }

  Future<void> handleSignOut({
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      final authService = ref.read(topPrixAuthProvider.notifier);

      await authService.signOut();

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
