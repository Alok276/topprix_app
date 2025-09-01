import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topprix/theme/app_theme.dart';

class LegalNoticePage extends StatelessWidget {
  const LegalNoticePage({super.key});

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
          'Legal Notice',
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
                  // Site Editor
                  _buildSiteEditorSection(),
                  const SizedBox(height: 24),

                  // Hosting Provider
                  _buildHostingProviderSection(),
                  const SizedBox(height: 24),

                  // Site Activity
                  _buildSiteActivitySection(),
                  const SizedBox(height: 24),

                  // Intellectual Property
                  _buildIntellectualPropertySection(),
                  const SizedBox(height: 24),

                  // Personal Data
                  _buildPersonalDataSection(),
                  const SizedBox(height: 24),

                  // Cookie Policy
                  _buildCookiePolicySection(),
                  const SizedBox(height: 24),

                  // Liability Limitation
                  _buildLiabilityLimitationSection(),
                  const SizedBox(height: 24),

                  // Applicable Law
                  _buildApplicableLawSection(),
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
                Icons.gavel,
                color: AppTheme.surfaceColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Legal Notice',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: August 2025',
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
                'Legal information and terms governing the use of TopPrix.re',
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

  Widget _buildSiteEditorSection() {
    return _buildSection(
      title: '1. Site Editor',
      icon: Icons.business,
      iconColor: AppTheme.primaryColor,
      children: [
        _buildLegalInfoCard([
          _buildLegalInfoRow('Commercial Name', 'TopPrix.re'),
          _buildLegalInfoRow('Legal Name', 'KLIKLOKAL'),
          _buildLegalInfoRow(
              'Legal Form', 'SASU – Simplified Joint Stock Company'),
          _buildLegalInfoRow('SIRET', '940 539 398 00013'),
          _buildLegalInfoRow('RCS', 'Saint-Denis de La Réunion'),
          _buildLegalInfoRow('Registered Office',
              '56 Rue du Général de Gaulle, 97400 Saint-Denis'),
          _buildLegalInfoRow('Share Capital', '150 €'),
          _buildLegalInfoRow('EU VAT Number', 'FR47940539398'),
        ]),
        const SizedBox(height: 12),
        _buildContactInfoCard(),
        const SizedBox(height: 12),
        _buildManagementInfoCard(),
      ],
    );
  }

  Widget _buildLegalInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildClickableInfoRow('Email', 'contact@topprix.re', Icons.email,
              () => _copyToClipboard('contact@topprix.re')),
          _buildClickableInfoRow('Phone', '+262 693 03 98 40', Icons.phone,
              () => _copyToClipboard('+262 693 03 98 40')),
        ],
      ),
    );
  }

  Widget _buildManagementInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Management',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegalInfoRow(
              'Publication Director', 'President of Kliklokal company'),
          _buildLegalInfoRow('Editorial Manager', 'Kliklokal'),
        ],
      ),
    );
  }

  Widget _buildLegalInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableInfoRow(
      String label, String value, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  '$label:',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const Icon(Icons.copy, color: AppTheme.primaryColor, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHostingProviderSection() {
    return _buildSection(
      title: '2. Hosting Provider',
      icon: Icons.cloud,
      iconColor: const Color(0xFF10B981),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_circle,
                      color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'OVHcloud – OVH SAS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLegalInfoRow(
                  'Address', '2 rue Kellermann – 59100 Roubaix – France'),
              _buildLegalInfoRow(
                  'SIRET', '424 761 419 00045 – RCS Lille Métropole'),
              _buildLegalInfoRow('Share Capital', '10 069 020 €'),
              _buildLegalInfoRow('Website', 'www.ovhcloud.com'),
              _buildLegalInfoRow(
                  'Phone', '1007 (free call from a landline in France)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiteActivitySection() {
    return _buildSection(
      title: '3. Site Activity',
      icon: Icons.description,
      iconColor: AppTheme.primaryColor,
      children: [
        const Text(
          'The website www.topprix.re is a digital platform specialized in disseminating local commercial information: catalogs, promotions, deals and offers published by professionals located in La Réunion.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The site is aimed at both:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildTargetAudienceItem(
                  'Professionals',
                  'wishing to distribute their commercial offers',
                  Icons.business_center),
              _buildTargetAudienceItem('Consumers',
                  'looking for the best prices near them', Icons.people),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetAudienceItem(
      String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
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
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  description,
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

  Widget _buildIntellectualPropertySection() {
    return _buildSection(
      title: '4. Intellectual Property',
      icon: Icons.copyright,
      iconColor: const Color(0xFFF59E0B),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Copyright Protection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'All elements present on the site (texts, images, logos, videos, source codes, structures, databases, etc.) are the exclusive property of Kliklokal company, unless otherwise stated.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF92400E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Any reproduction, representation, adaptation, distribution or exploitation, total or partial, without prior written authorization, is prohibited and constitutes counterfeiting punishable by articles L.335-2 and following of the Intellectual Property Code.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDataSection() {
    return _buildSection(
      title: '5. Personal Data',
      icon: Icons.privacy_tip,
      iconColor: const Color(0xFF3B82F6),
      children: [
        const Text(
          'The TopPrix.re site collects and processes personal data in accordance with the General Data Protection Regulation (GDPR – EU 2016/679) and the modified Data Protection Act.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Processing Purposes:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 8),
              _buildDataPurposeItem('Creation and management of user accounts'),
              _buildDataPurposeItem('Response to requests via forms'),
              _buildDataPurposeItem(
                  'Sending newsletters (with explicit consent)'),
              _buildDataPurposeItem(
                  'Anonymous statistical analysis of site traffic'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Rights:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'In accordance with current legislation, you have the following rights: access, rectification, deletion, opposition, portability and limitation of processing.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.email, color: Color(0xFF10B981), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'To exercise your rights, write to: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      'contact@topprix.re',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataPurposeItem(String text) {
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
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCookiePolicySection() {
    return _buildSection(
      title: '6. Cookie Policy',
      icon: Icons.cookie,
      iconColor: AppTheme.primaryColor,
      children: [
        const Text(
          'The site uses cookies to ensure:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _buildCookieItem('Technical functioning of the site'),
        _buildCookieItem(
            'Anonymous audience measurements (via Google Analytics or equivalent)'),
        _buildCookieItem('Continuous improvement of user experience'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'You can accept, refuse or customize cookies at any time via the preference management banner or your browser settings.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
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
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilityLimitationSection() {
    return _buildSection(
      title: '7. Limitation of Liability',
      icon: Icons.security,
      iconColor: const Color(0xFFEF4444),
      children: [
        const Text(
          'Kliklokal company strives to provide reliable and up-to-date information. It cannot be held responsible for:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _buildLiabilityItem(
            'Involuntary errors or omissions', Icons.error_outline),
        _buildLiabilityItem(
            'Temporary inaccessibility of the site', Icons.cloud_off),
        _buildLiabilityItem('Consequences of using the site or its content',
            Icons.warning_amber),
        _buildLiabilityItem(
            'Content published by third parties (ads, comments, etc.), except obviously active moderation',
            Icons.forum),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Users are responsible for verifying information before making any purchase or decision.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFEF4444),
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

  Widget _buildLiabilityItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFEF4444), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicableLawSection() {
    return _buildSection(
      title: '8. Applicable Law – Competent Jurisdiction',
      icon: Icons.balance,
      iconColor: AppTheme.primaryColor,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'French Law',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'These legal notices are governed by French law.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E40AF),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_city,
                      color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Jurisdiction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Any dispute relating to the use of the site or its content falls under the exclusive jurisdiction of the courts of Saint-Denis de La Réunion, except imperative legal provisions to the contrary (particularly for consumers residing in metropolitan France or the EU).',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E40AF),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Note: ScaffoldMessenger would need context, but since this is a static method,
    // you might want to implement this differently in your actual app
  }
}
