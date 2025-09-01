import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topprix/theme/app_theme.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
          'Terms & Conditions',
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

                  // Article 1 - Purpose
                  _buildPurposeSection(),
                  const SizedBox(height: 24),

                  // Article 2 - Pricing & Registration
                  _buildPricingSection(),
                  const SizedBox(height: 24),

                  // Article 3 - Service Access
                  _buildServiceAccessSection(),
                  const SizedBox(height: 24),

                  // Article 4 - Right of Withdrawal
                  _buildWithdrawalRightSection(),
                  const SizedBox(height: 24),

                  // Article 5 - Responsibility
                  _buildResponsibilitySection(),
                  const SizedBox(height: 24),

                  // Article 6 - Personal Data
                  _buildPersonalDataSection(),
                  const SizedBox(height: 24),

                  // Article 7 - Complaints & Mediation
                  _buildComplaintsSection(),
                  const SizedBox(height: 24),

                  // Article 8 - Applicable Law
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
                Icons.description,
                color: AppTheme.surfaceColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terms and Conditions of Sale (CGV)',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Last updated: August 2025',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
                'Contractual terms governing the relationship between TopPrix.re and its users',
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
        _buildLegalInfoGrid(),
      ],
    );
  }

  Widget _buildLegalInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLegalInfoItem('Legal Name', 'KLIKLOKAL')),
              Expanded(
                  child: _buildLegalInfoItem('Commercial Name', 'TopPrix.re')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLegalInfoItem('Legal Form', 'SASU')),
              Expanded(
                  child: _buildLegalInfoItem('SIRET', '940 539 398 00013')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLegalInfoItem('RCS', 'Saint-Denis')),
              Expanded(child: _buildLegalInfoItem('Capital', '150 €')),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegalInfoItem(
              'Address', '56 Rue du Général de Gaulle, 97400 Saint-Denis'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildContactInfoItem(
                      'Email', 'contact@topprix.re', Icons.email)),
              Expanded(
                  child: _buildContactInfoItem(
                      'Phone', '+262 693 03 98 40', Icons.phone)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoItem(String label, String value, IconData icon) {
    return InkWell(
      onTap: () => _copyToClipboard(value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeSection() {
    return _buildSection(
      title: 'Article 1 – Purpose',
      icon: Icons.flag,
      iconColor: const Color(0xFF10B981),
      children: [
        const Text(
          'These Terms and Conditions of Sale (CGV) govern the contractual relationships between KLIKLOKAL company (TopPrix.re) and any client (consumer or professional) wishing to benefit from the paid services offered on the TopPrix.re platform, such as:',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          'For Consumers',
          'Free access to price comparison and product promotions in various sectors (food, electronics, fashion, travel, hotels, automotive, agencies, jobs, etc.)',
          Icons.people,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          'For Businesses',
          'Visibility solutions via subscriptions, targeted advertising, affiliate partnerships, and market analysis reports',
          Icons.business_center,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'By accessing paid services, the client accepts these Terms and Conditions without reservation.',
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

  Widget _buildServiceCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return _buildSection(
      title: 'Article 2 – Pricing & Registration',
      icon: Icons.payment,
      iconColor: const Color(0xFFF59E0B),
      children: [
        _buildPricingInfoCard(),
        const SizedBox(height: 16),
        _buildPaymentInfoCard(),
      ],
    );
  }

  Widget _buildPricingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Business Registration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Registration is open to businesses wishing to promote their products on the platform. To access TopPrix.re functionalities, businesses must subscribe to one of the subscription plans (Basic, Intermediate, Premium).',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF92400E),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Pricing & Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPaymentPoint(
              'Prices are expressed in euros excluding tax (HT) and may change at any time'),
          _buildPaymentPoint(
              'Payment is made via secure means (credit card, bank transfer, Stripe)'),
          _buildPaymentPoint(
              'Payment is due immediately, unless otherwise stated'),
          _buildPaymentPoint(
              'For professionals, late payment penalties may apply'),
          _buildPaymentPoint(
              'Any price modification will be communicated with 30 days notice'),
        ],
      ),
    );
  }

  Widget _buildPaymentPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAccessSection() {
    return _buildSection(
      title: 'Article 3 – Service Access & Publication',
      icon: Icons.publish,
      iconColor: AppTheme.primaryColor,
      children: [
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
                'Publication Requirements:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildPublicationPoint(
                  'Publication is subject to platform acceptance and compliance with internal rules'),
              _buildPublicationPoint(
                  'Content must be legal, non-deceptive, and comply with current legislation'),
              _buildPublicationPoint(
                  'Ads are published for a specified duration without automatic renewal'),
              _buildPublicationPoint(
                  'TopPrix.re reserves the right to refuse or remove any non-compliant content'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPublicationPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle,
              color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B46C1),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalRightSection() {
    return _buildSection(
      title: 'Article 4 – Right of Withdrawal',
      icon: Icons.undo,
      iconColor: const Color(0xFFEF4444),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Withdrawal Rights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'In accordance with article L221-28 of the Consumer Code, the 14-day withdrawal right does not apply to services fully executed with the consumer\'s prior express agreement and express waiver of this right.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFDC2626),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cancellation Policy:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 8),
              _buildWithdrawalPoint(
                  'Customers are informed before order validation that they waive their withdrawal right when service is provided immediately'),
              _buildWithdrawalPoint(
                  'Businesses can cancel their subscription with 30 days notice before the end of the current billing period'),
              _buildWithdrawalPoint(
                  'TopPrix.re reserves the right to suspend or terminate a subscription for Terms violation'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFDC2626),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilitySection() {
    return _buildSection(
      title: 'Article 5 – Responsibility',
      icon: Icons.security,
      iconColor: const Color(0xFF10B981),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Platform Role',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Information, catalogs, advertisements and commercial offers visible on TopPrix.re are broadcast directly by partner merchants. Kliklokal company, publisher of TopPrix.re, acts only as a technical intermediary platform and does not intervene in the content of online offers.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF059669),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildResponsibilityCard(
          'Merchant Responsibility',
          'Each partner merchant is responsible for providing accurate, complete and up-to-date information. TopPrix.re does not edit, market or guarantee the products, services or promotions relayed on the platform.',
          Icons.store,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildResponsibilityCard(
          'Commercial Relations',
          'Any commercial relationship arising from interactions on TopPrix.re takes place outside the scope of TopPrix.re\'s responsibility. You will be subject to the partner merchant\'s terms and conditions.',
          Icons.handshake,
          const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 12),
        _buildResponsibilityCard(
          'Information Accuracy',
          'While TopPrix.re strives to ensure reliability and regular updating of information, it cannot control the real-time accuracy of data provided by partners.',
          Icons.verified,
          AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildResponsibilityCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataSection() {
    return _buildSection(
      title: 'Article 6 – Personal Data (GDPR)',
      icon: Icons.privacy_tip,
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
              const Text(
                'TopPrix.re collects personal data as part of using its services. This data is processed in accordance with the General Data Protection Regulation (GDPR).',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E40AF),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.policy,
                      color: AppTheme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'User Rights:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Users have rights of access, rectification, deletion and opposition by writing to: contact@topprix.re',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E40AF),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'For more information, please consult our Privacy Policy.',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintsSection() {
    return _buildSection(
      title: 'Article 7 – Complaints & Mediation',
      icon: Icons.support_agent,
      iconColor: const Color(0xFFF59E0B),
      children: [
        _buildComplaintCard(),
        const SizedBox(height: 16),
        _buildMediationCard(),
      ],
    );
  }

  Widget _buildComplaintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.email, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Complaints',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            children: [
              const Text(
                'Any complaint can be sent by email to: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF92400E),
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard('contact@topprix.re'),
                child: const Text(
                  'contact@topprix.re',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              const Icon(Icons.balance, color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Consumer Mediation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'In accordance with articles L612-1 and following of the Consumer Code, consumers can use the following mediator free of charge:',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF1E40AF),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildMediatorInfo(
            'CNPM - Consumer Mediation',
            '27 Avenue de la Libération, 42400 Saint-Chamond',
            'https://www.cnpm-mediation-consommation.eu',
          ),
          const SizedBox(height: 12),
          _buildMediatorInfo(
            'European ODR Platform',
            'Online Dispute Resolution',
            'https://ec.europa.eu/consumers/odr',
          ),
        ],
      ),
    );
  }

  Widget _buildMediatorInfo(String name, String address, String website) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _copyToClipboard(website),
            child: Text(
              website,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF3B82F6),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicableLawSection() {
    return _buildSection(
      title: 'Article 8 – Applicable Law & Jurisdiction',
      icon: Icons.balance,
      iconColor: AppTheme.primaryColor,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
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
              const SizedBox(height: 8),
              const Text(
                'These Terms and Conditions are subject to French law.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E40AF),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.location_city,
                      color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
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
              _buildJurisdictionCard(
                'For Consumers',
                'In case of dispute, consumers can refer to either the territorially competent courts under the Civil Procedure Code, or the court of the place where they resided at the time of conclusion of the contract.',
                Icons.people,
                const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
              _buildJurisdictionCard(
                'For Professionals',
                'In the absence of an amicable solution, the competent court will be that of Saint-Denis de La Réunion for professionals.',
                Icons.business,
                const Color(0xFF3B82F6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJurisdictionCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
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
                    height: 1.4,
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
    // Note: In a real implementation, you'd show a SnackBar here
    // ScaffoldMessenger.of(context).showSnackBar(...)
  }
}
