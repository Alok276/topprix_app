import 'package:flutter/material.dart';
import 'package:topprix/theme/app_theme.dart';

class CookiePolicyPage extends StatefulWidget {
  const CookiePolicyPage({super.key});

  @override
  State<CookiePolicyPage> createState() => _CookiePolicyPageState();
}

class _CookiePolicyPageState extends State<CookiePolicyPage> {
  bool analyticsEnabled = true;
  bool advertisingEnabled = false;
  bool socialEnabled = false;
  bool preferencesEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cookie Policy',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // What are cookies
                  _buildWhatAreCookiesSection(),
                  const SizedBox(height: 24),

                  // Who deposits cookies
                  _buildWhoDepositsCookiesSection(),
                  const SizedBox(height: 24),

                  // Cookie types with toggles
                  _buildCookieTypesSection(),
                  const SizedBox(height: 24),

                  // Consent management
                  _buildConsentManagementSection(),
                  const SizedBox(height: 24),

                  // Retention period
                  _buildRetentionPeriodSection(),
                  const SizedBox(height: 24),

                  // Browser management
                  _buildBrowserManagementSection(),
                  const SizedBox(height: 24),

                  // Contact
                  _buildContactSection(),
                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.cookie,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cookie Policy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: August 2025',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Manage your cookie preferences and understand how we use cookies on TopPrix.re',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWhatAreCookiesSection() {
    return _buildSection(
      title: 'What is a Cookie?',
      icon: Icons.help_outline,
      iconColor: const Color(0xFF6366F1),
      children: [
        const Text(
          'A cookie is a small text file stored on the user\'s device (computer, mobile, tablet) when browsing a website. It allows to collect anonymous information about navigation, record user preferences, or measure website audience.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Cookies help improve your browsing experience and website functionality.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhoDepositsCookiesSection() {
    return _buildSection(
      title: 'Who Deposits Cookies on TopPrix.re?',
      icon: Icons.business,
      iconColor: const Color(0xFF10B981),
      children: [
        const Text(
          'Cookies used on TopPrix.re can be:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _buildCookieSourceItem(
          'Internal Cookies',
          'Deposited directly by TopPrix.re',
          Icons.home,
          const Color(0xFF10B981),
        ),
        _buildCookieSourceItem(
          'Third-party Cookies',
          'By third-party partners for statistics, advertising or social media sharing services',
          Icons.public,
          const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildCookieSourceItem(
      String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCookieTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings,
                  color: Color(0xFF8B5CF6), size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cookie Types & Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Strictly necessary cookies (always enabled)
        _buildCookieTypeCard(
          title: 'Strictly Necessary Cookies',
          description:
              'Ensure proper functioning of the site, security, session management',
          color: const Color(0xFF10B981),
          icon: Icons.security,
          isRequired: true,
          isEnabled: true,
          onChanged: null,
        ),

        // Analytics cookies
        _buildCookieTypeCard(
          title: 'Analytics Cookies',
          description:
              'Anonymously track site traffic and user journeys to improve our services (e.g. Google Analytics)',
          color: const Color(0xFF3B82F6),
          icon: Icons.analytics,
          isRequired: false,
          isEnabled: analyticsEnabled,
          onChanged: (value) => setState(() => analyticsEnabled = value),
        ),

        // Advertising cookies
        _buildCookieTypeCard(
          title: 'Advertising Cookies',
          description:
              'Allow displaying personalized ads according to your interests',
          color: const Color(0xFFF59E0B),
          icon: Icons.ads_click,
          isRequired: false,
          isEnabled: advertisingEnabled,
          onChanged: (value) => setState(() => advertisingEnabled = value),
        ),

        // Social media cookies
        _buildCookieTypeCard(
          title: 'Social Media Cookies',
          description:
              'Allow content sharing and social media integration (Meta, Instagram...)',
          color: const Color(0xFFEF4444),
          icon: Icons.share,
          isRequired: false,
          isEnabled: socialEnabled,
          onChanged: (value) => setState(() => socialEnabled = value),
        ),

        // Preference cookies
        _buildCookieTypeCard(
          title: 'Preference Cookies',
          description: 'Remember your navigation choices and user preferences',
          color: const Color(0xFF8B5CF6),
          icon: Icons.tune,
          isRequired: false,
          isEnabled: preferencesEnabled,
          onChanged: (value) => setState(() => preferencesEnabled = value),
        ),
      ],
    );
  }

  Widget _buildCookieTypeCard({
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required bool isRequired,
    required bool isEnabled,
    required Function(bool)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Switch(
                  value: isEnabled,
                  onChanged: onChanged,
                  activeColor: color,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '❌ Consent not required - Essential for website functionality',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '✅ Consent required - You can enable/disable this type of cookie',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsentManagementSection() {
    return _buildSection(
      title: 'Consent Management',
      icon: Icons.manage_accounts,
      iconColor: const Color(0xFFF59E0B),
      children: [
        const Text(
          'During your first visit to TopPrix.re, a cookie management banner is presented. You can then:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _buildConsentOption(
            'Accept all cookies', Icons.check_circle, const Color(0xFF10B981)),
        _buildConsentOption('Refuse all non-necessary cookies', Icons.cancel,
            const Color(0xFFEF4444)),
        _buildConsentOption('Customize your preferences, service by service',
            Icons.tune, const Color(0xFF8B5CF6)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'You can modify your choices at any time by clicking on "Manage my cookies" at the bottom of the page.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsentOption(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionPeriodSection() {
    return _buildSection(
      title: 'Cookie Retention Period',
      icon: Icons.schedule,
      iconColor: const Color(0xFF8B5CF6),
      children: [
        _buildRetentionItem('Consent validity',
            '6 months maximum (CNIL recommendation)', Icons.gavel),
        _buildRetentionItem(
            'Cookie storage',
            '13 months maximum, unless manually deleted via your browser',
            Icons.storage),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'After 6 months, you will be asked again for your consent preferences.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8B5CF6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRetentionItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowserManagementSection() {
    return _buildSection(
      title: 'Browser Cookie Management',
      icon: Icons.web,
      iconColor: const Color(0xFF3B82F6),
      children: [
        const Text(
          'You can also manage cookies directly through your browser settings:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _buildBrowserLink('Google Chrome',
            'https://support.google.com/chrome/answer/95647', Icons.web),
        _buildBrowserLink(
            'Mozilla Firefox',
            'https://support.mozilla.org/fr/kb/cookies-informations-sites-enregistrent',
            Icons.web),
        _buildBrowserLink(
            'Safari',
            'https://support.apple.com/fr-fr/guide/safari/sfri11471/mac',
            Icons.web),
        _buildBrowserLink('Microsoft Edge',
            'https://support.microsoft.com/fr-fr/microsoft-edge', Icons.web),
      ],
    );
  }

  Widget _buildBrowserLink(String browserName, String url, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              browserName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          const Icon(Icons.open_in_new, color: Color(0xFF3B82F6), size: 16),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Contact',
      icon: Icons.contact_support,
      iconColor: const Color(0xFF10B981),
      children: [
        const Text(
          'For any questions regarding our cookie policy or your personal data processing, you can write to us at:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _buildContactItem('Email', 'contact@topprix.re'),
        _buildContactItem('Company', 'KLIKLOKAL'),
        _buildContactItem('Address',
            '56 Rue du Général de Gaulle, 97400 Saint-Denis, La Réunion'),
      ],
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save preferences
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save My Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Accept all
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _acceptAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Accept All Cookies',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Reject all optional
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _rejectAllOptional,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reject All Optional Cookies',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _savePreferences() {
    // TODO: Implement save preferences logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cookie preferences saved!\n'
          'Analytics: ${analyticsEnabled ? "Enabled" : "Disabled"}\n'
          'Advertising: ${advertisingEnabled ? "Enabled" : "Disabled"}\n'
          'Social Media: ${socialEnabled ? "Enabled" : "Disabled"}\n'
          'Preferences: ${preferencesEnabled ? "Enabled" : "Disabled"}',
        ),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }

  void _acceptAll() {
    setState(() {
      analyticsEnabled = true;
      advertisingEnabled = true;
      socialEnabled = true;
      preferencesEnabled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All cookies accepted!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    Navigator.pop(context);
  }

  void _rejectAllOptional() {
    setState(() {
      analyticsEnabled = false;
      advertisingEnabled = false;
      socialEnabled = false;
      preferencesEnabled = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'All optional cookies rejected. Only necessary cookies remain active.'),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
    Navigator.pop(context);
  }
}
