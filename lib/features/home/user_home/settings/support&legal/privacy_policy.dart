import 'package:flutter/material.dart';
import 'package:topprix/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
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
                  // Legal Information
                  _buildLegalInformationSection(),
                  const SizedBox(height: 24),

                  // Data Collection
                  _buildDataCollectionSection(),
                  const SizedBox(height: 24),

                  // Data Usage
                  _buildDataUsageSection(),
                  const SizedBox(height: 24),

                  // Legal Basis
                  _buildLegalBasisSection(),
                  const SizedBox(height: 24),

                  // Data Retention
                  _buildDataRetentionSection(),
                  const SizedBox(height: 24),

                  // Data Sharing
                  _buildDataSharingSection(),
                  const SizedBox(height: 24),

                  // Data Protection
                  _buildDataProtectionSection(),
                  const SizedBox(height: 24),

                  // Your Rights
                  _buildYourRightsSection(),
                  const SizedBox(height: 24),

                  // Cookies
                  _buildCookiesSection(),
                  const SizedBox(height: 24),

                  // Policy Updates
                  _buildPolicyUpdatesSection(),
                  const SizedBox(height: 24),

                  // Contact
                  _buildContactSection(),
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
          colors: [AppTheme.primaryColor, AppTheme.primaryColor],
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
                color: AppTheme.surfaceColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.privacy_tip,
                color: AppTheme.surfaceColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Privacy Policy',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: July 2025',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'At TopPrix.re, we attach paramount importance to protecting your privacy and personal data.',
                style: TextStyle(
                  color: AppTheme.surfaceColor,
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
        color: AppTheme.surfaceColor,
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

  Widget _buildLegalInformationSection() {
    return _buildSection(
      title: 'Legal Information',
      icon: Icons.business,
      iconColor: AppTheme.primaryColor,
      children: [
        _buildInfoRow('Company', 'Kliklokal SASU'),
        _buildInfoRow('Address',
            '56 Rue du Général de Gaulle, 97400, Saint-Denis Réunion'),
        _buildInfoRow('SIRET', '940 539 398 00013'),
        _buildInfoRow('Email', 'contact@topprix.re'),
        _buildInfoRow('Phone', '0693039840'),
        const SizedBox(height: 12),
        const Text(
          'The data controller is Kliklokal company.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCollectionSection() {
    return _buildSection(
      title: 'What Personal Data Do We Collect?',
      icon: Icons.data_usage,
      iconColor: const Color(0xFF10B981),
      children: [
        const Text(
          'We collect only the data strictly necessary for the proper functioning of our site and managing your orders:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildDataItem(
            'Identification information: name, first name, email address, phone number, delivery address'),
        _buildDataItem('User account data (if you create an account)'),
        _buildDataItem(
            'Banking data necessary for payment (transmitted securely to our providers)'),
        _buildDataItem(
            'Navigation data on the site (IP address, browser type, pages visited, navigation duration) for security and service improvement purposes'),
        _buildDataItem('Location data only if you authorize access'),
      ],
    );
  }

  Widget _buildDataItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
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

  Widget _buildDataUsageSection() {
    return _buildSection(
      title: 'Why Do We Collect This Data?',
      icon: Icons.help_outline,
      iconColor: AppTheme.primaryColor,
      children: [
        const Text(
          'Your data is used only for the following purposes:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildUsageItem(
            'Manage your account and orders (preparation, payment, delivery)',
            Icons.shopping_cart),
        _buildUsageItem(
            'Send you important information related to your orders or customer service',
            Icons.email),
        _buildUsageItem(
            'Inform you, with your prior consent, of commercial offers and promotions via email or SMS',
            Icons.campaign),
        _buildUsageItem('Improve the security and performance of our website',
            Icons.security),
        _buildUsageItem(
            'Comply with legal and regulatory obligations (e.g., taxation, fraud prevention)',
            Icons.gavel),
      ],
    );
  }

  Widget _buildUsageItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
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

  Widget _buildLegalBasisSection() {
    return _buildSection(
      title: 'Legal Basis for Processing Your Data',
      icon: Icons.balance,
      iconColor: const Color(0xFFF59E0B),
      children: [
        _buildLegalBasisItem('Contract execution',
            'to process your orders and deliveries', const Color(0xFF3B82F6)),
        _buildLegalBasisItem(
            'Consent',
            'for sending promotional offers and newsletters (you can withdraw this consent at any time)',
            const Color(0xFF10B981)),
        _buildLegalBasisItem(
            'Legal obligation',
            'to comply with our legal duties (e.g., invoice retention)',
            const Color(0xFFF59E0B)),
        _buildLegalBasisItem(
            'Legitimate interest',
            'to ensure site security and prevent fraud',
            const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildLegalBasisItem(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
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
    );
  }

  Widget _buildDataRetentionSection() {
    return _buildSection(
      title: 'Data Retention Period',
      icon: Icons.schedule,
      iconColor: AppTheme.primaryColor,
      children: [
        _buildRetentionItem('Order and invoice data',
            '5 years (legal duration)', Icons.receipt),
        _buildRetentionItem(
            'Navigation data and logs', '12 months maximum', Icons.web),
        _buildRetentionItem('Marketing data (emails)',
            'Until your effective unsubscription', Icons.unsubscribe),
      ],
    );
  }

  Widget _buildRetentionItem(String type, String duration, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSharingSection() {
    return _buildSection(
      title: 'Data Sharing',
      icon: Icons.share,
      iconColor: const Color(0xFF10B981),
      children: [
        const Text(
          'We only share your data with essential third parties:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildSharingItem(
            'Our secure payment partners (Stripe and banks)', Icons.payment),
        _buildSharingItem(
            'Our logistics providers to ensure delivery', Icons.local_shipping),
        _buildSharingItem(
            'Competent authorities in case of legal or judicial obligation',
            Icons.security),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'No other sharing or sale of your data is carried out without your explicit consent.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 18),
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

  Widget _buildDataProtectionSection() {
    return _buildSection(
      title: 'How We Protect Your Data',
      icon: Icons.shield,
      iconColor: const Color(0xFFEF4444),
      children: [
        const Text(
          'We implement rigorous technical and organizational security measures:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildProtectionItem(
            'SSL encryption of all data exchanged on the site', Icons.lock),
        _buildProtectionItem(
            'Strict control of data access (limited and trained personnel)',
            Icons.admin_panel_settings),
        _buildProtectionItem('Regular backups', Icons.backup),
        _buildProtectionItem(
            'Continuous monitoring against intrusions and computer attacks',
            Icons.monitor),
      ],
    );
  }

  Widget _buildProtectionItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFEF4444), size: 18),
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

  Widget _buildYourRightsSection() {
    return _buildSection(
      title: 'Your Rights and How to Exercise Them',
      icon: Icons.person_outline,
      iconColor: AppTheme.primaryColor,
      children: [
        const Text(
          'In accordance with the "Informatique et Libertés" law and GDPR, you have the right to:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildRightItem(
            'Access your personal data that we hold', Icons.visibility),
        _buildRightItem(
            'Request rectification of inaccurate or incomplete data',
            Icons.edit),
        _buildRightItem(
            'Request deletion of your data, subject to legal obligations',
            Icons.delete),
        _buildRightItem(
            'Limit the processing of your data in certain cases', Icons.pause),
        _buildRightItem(
            'Object to the processing of your data for legitimate reasons',
            Icons.block),
        _buildRightItem(
            'Withdraw your consent at any time for marketing communications',
            Icons.unsubscribe),
        _buildRightItem(
            'Request data portability (transfer to another provider)',
            Icons.import_export),
        _buildRightItem(
            'File a complaint with CNIL if you believe your rights are not respected',
            Icons.report),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To exercise these rights, contact us at:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'contact@topprix.re',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'We commit to responding within a maximum of two months.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
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

  Widget _buildCookiesSection() {
    return _buildSection(
      title: 'Cookie Usage',
      icon: Icons.cookie,
      iconColor: const Color(0xFFF59E0B),
      children: [
        const Text(
          'We use cookies to:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildCookieItem('Guarantee site security'),
        _buildCookieItem(
            'Improve your user experience (session memory, preferences)'),
        _buildCookieItem(
            'Analyze site usage for anonymous statistical purposes'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'You can manage or refuse cookies through your browser settings at any time.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCookieItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
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

  Widget _buildPolicyUpdatesSection() {
    return _buildSection(
      title: 'Policy Modifications',
      icon: Icons.update,
      iconColor: AppTheme.primaryColor,
      children: [
        const Text(
          'We may modify this policy to comply with legal or technical developments. The update date is indicated at the top. We invite you to consult it regularly.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Contact',
      icon: Icons.contact_support,
      iconColor: const Color(0xFF10B981),
      children: [
        const Text(
          'For any questions regarding the protection of your personal data, you can contact us at:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem('Email', 'contact@topprix.re', Icons.email),
        _buildContactItem('Phone', '0693039840', Icons.phone),
        _buildContactItem(
            'Address',
            '56 Rue du Général de Gaulle, 97400, Saint-Denis Réunion',
            Icons.location_on),
      ],
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
