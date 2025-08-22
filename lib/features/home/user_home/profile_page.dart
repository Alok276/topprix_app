import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/features/auth/service/auth_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentBackendUserProvider);
    final firebaseUser = ref.watch(currentFirebaseUserProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          _buildProfileAppBar(user, firebaseUser),

          // Profile Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Quick Stats Card
                      _buildQuickStatsCard(),
                      const SizedBox(height: 24),

                      // Account Settings Section
                      _buildAccountSection(),
                      const SizedBox(height: 16),

                      // Preferences Section
                      _buildPreferencesSection(),
                      const SizedBox(height: 16),

                      // Activity Section
                      _buildActivitySection(),
                      const SizedBox(height: 16),

                      // Support & Legal Section
                      _buildSupportSection(),
                      const SizedBox(height: 16),

                      // App Information & Sign Out
                      _buildAppInfoSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAppBar(dynamic user, dynamic firebaseUser) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => null //_editProfile(),
            ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'share_profile':
                _shareProfile();
                break;
              case 'export_data':
                _exportUserData();
                break;
              case 'account_backup':
                _backupAccount();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share_profile',
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Share Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export_data',
              child: Row(
                children: [
                  Icon(Icons.download, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Export Data'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'account_backup',
              child: Row(
                children: [
                  Icon(Icons.backup, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Backup Account'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFF06B6D4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // Space for app bar

                // Profile Picture with Status
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(46),
                        child: firebaseUser?.photoURL != null
                            ? Image.network(
                                firebaseUser!.photoURL!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultAvatar(user?.name),
                              )
                            : _buildDefaultAvatar(user?.name),
                      ),
                    ),

                    // Online Status Indicator
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),

                    // Premium Badge (if applicable)
                    if (user?.hasActiveSubscription == true)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // User Info
                Text(
                  user?.name ?? firebaseUser?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Email with verification status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.email ?? firebaseUser?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if (firebaseUser?.emailVerified == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                if (user?.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        user!.location!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Member Since
                Text(
                  'Member since ${_formatMemberSince(user?.createdAt ?? DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String? name) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(46),
      ),
      child: Center(
        child: Text(
          name?.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              const Text(
                'Your Savings Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'This Month',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: '12',
                  label: 'Saved\nCoupons',
                  icon: Icons.confirmation_number,
                  color: Colors.green,
                  trend: '+3',
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '5',
                  label: 'Favorite\nStores',
                  icon: Icons.store,
                  color: Colors.blue,
                  trend: '+1',
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '\$245',
                  label: 'Total\nSaved',
                  icon: Icons.savings,
                  color: Colors.orange,
                  trend: '+\$45',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        if (trend != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trend,
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Account Settings',
      icon: Icons.person,
      children: [
        _buildSettingsItem(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => null // _editProfile(),
            ),
        _buildSettingsItem(
            icon: Icons.security,
            title: 'Password & Security',
            subtitle: 'Change password and security settings',
            onTap: () => null //_navigateToSecurity(),
            ),
        _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            showBadge: true,
            onTap: () => null //_navigateToNotifications(),
            ),
        _buildSettingsItem(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            onTap: () => null //_navigateToPaymentMethods(),
            ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.tune,
      children: [
        _buildSettingsItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () => null //_navigateToLanguage(),
            ),
        _buildSettingsItem(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: 'Light mode',
            onTap: () => null //_navigateToTheme(),
            ),
        _buildSettingsItem(
            icon: Icons.location_on_outlined,
            title: 'Location Services',
            subtitle: 'Manage location preferences',
            onTap: () => null //_navigateToLocation(),
            ),
        _buildSettingsItem(
            icon: Icons.category_outlined,
            title: 'Preferred Categories',
            subtitle: 'Customize your interests',
            onTap: () => null //_navigateToPreferredCategories(),
            ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return _buildSection(
      title: 'Activity & Data',
      icon: Icons.analytics,
      children: [
        _buildSettingsItem(
          icon: Icons.history,
          title: 'Purchase History',
          subtitle: 'View your transaction history',
          onTap: () => _navigateToPurchaseHistory(),
        ),
        _buildSettingsItem(
          icon: Icons.insights,
          title: 'Savings Analytics',
          subtitle: 'Track your savings over time',
          onTap: () => _navigateToSavingsAnalytics(),
        ),
        _buildSettingsItem(
          icon: Icons.download,
          title: 'Download Data',
          subtitle: 'Export your account data',
          onTap: () => _exportUserData(),
        ),
        _buildSettingsItem(
          icon: Icons.delete_outline,
          title: 'Clear Data',
          subtitle: 'Remove saved items and history',
          onTap: () => _clearUserData(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support & Legal',
      icon: Icons.support,
      children: [
        _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help and support',
            onTap: () => null //_navigateToHelpCenter(),
            ),
        _buildSettingsItem(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Help us improve TopPrix',
            onTap: () => null //_navigateToFeedback(),
            ),
        _buildSettingsItem(
            icon: Icons.star_outline,
            title: 'Rate App',
            subtitle: 'Rate TopPrix on the App Store',
            onTap: () => null //_navigateToRateApp(),
            ),
        _buildSettingsItem(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Read our terms of service',
            onTap: () => null //_navigateToTerms(),
            ),
        _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how we protect your data',
            onTap: () => null //_navigateToPrivacy(),
            ),
        _buildSettingsItem(
            icon: Icons.recycling,
            title: 'E-Waste Policy',
            subtitle: 'Our environmental commitment',
            onTap: () => null //_navigateToEWaste(),
            ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TopPrix',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Version 1.0.0 (Build 1)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your local deals and coupons companion. Save money while shopping at your favorite stores.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareApp(),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share App'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToAbout(),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('About'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showSignOutDialog(),
              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6366F1), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          ...children.map((child) {
            final isLast = children.indexOf(child) == children.length - 1;
            return Column(
              children: [
                child,
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Colors.grey[200],
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          if (showBadge) const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  // Helper methods
  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return 'this month';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  // Navigation methods
  // void _editProfile() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const EditProfilePage()),
  //   );
  // }

  // void _navigateToSecurity() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const SecurityPage()),
  //   );
  // }

  // void _navigateToNotifications() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
  //   );
  // }

  // void _navigateToPaymentMethods() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
  //   );
  // }

  // void _navigateToLanguage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LanguagePage()),
  //   );
  // }

  // void _navigateToTheme() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const ThemePage()),
  //   );
  // }

  // void _navigateToLocation() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LocationPage()),
  //   );
  // }

  // void _navigateToPreferredCategories() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const PreferredCategoriesPage()),
  //   );
  // }

  void _navigateToPurchaseHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase History coming soon!')),
    );
  }

  void _navigateToSavingsAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Savings Analytics coming soon!')),
    );
  }

  // void _navigateToHelpCenter() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HelpCenterPage()),
  //   );
  // }

  // void _navigateToFeedback() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const FeedbackPage()),
  //   );
  // }

  void _navigateToRateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate app feature coming soon!')),
    );
  }

  // void _navigateToTerms() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const TermsAndConditionsPage()),
  //   );
  // }

  // void _navigateToPrivacy() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
  //   );
  // }

  // void _navigateToEWaste() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const EWastePage()),
  //   );
  // }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share profile feature coming soon!')),
    );
  }

  void _exportUserData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
            'Your data will be exported as a JSON file. This may take a few moments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDataExport();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _performDataExport() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _backupAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Backup Account'),
          ],
        ),
        content: const Text(
          'Create a secure backup of your account data. This backup can be used to restore your account if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performAccountBackup();
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _performAccountBackup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Creating backup...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account backup created successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Navigate to backup details
            },
          ),
        ),
      );
    });
  }

  void _clearUserData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Clear Data'),
          ],
        ),
        content: const Text(
          'This will remove all your saved items, history, and cached data. Your account and preferences will remain intact. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDataClear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _performDataClear() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Clearing data...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _shareApp() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share TopPrix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Help your friends save money with TopPrix!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () => _shareViaMessage(),
                ),
                _buildShareOption(
                  icon: Icons.mail,
                  label: 'Email',
                  onTap: () => _shareViaEmail(),
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () => _copyAppLink(),
                ),
                _buildShareOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () => _shareViaOther(),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _shareViaMessage() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Messages...')),
    );
  }

  void _shareViaEmail() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Email...')),
    );
  }

  void _copyAppLink() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App link copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareViaOther() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening share options...')),
    );
  }

  void _navigateToAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('About TopPrix'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0 (Build 1)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'TopPrix is your ultimate companion for finding local deals, coupons, and saving money while shopping at your favorite stores.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 TopPrix. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening website...')),
              );
            },
            child: const Text('Visit Website'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out? You\'ll need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSignOut() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final authService = ref.read(topPrixAuthProvider.notifier);
      await authService.signOut();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Navigate to login page
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
