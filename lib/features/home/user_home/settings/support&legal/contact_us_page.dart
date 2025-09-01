import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _merchantController = TextEditingController();

  String _selectedInquiryType = 'General Question';
  bool _isSubmitting = false;

  final List<String> _inquiryTypes = [
    'General Question',
    'Technical Support',
    'Product/Service Issue',
    'Partnership Request',
    'Merchant Complaint',
    'Data Protection Request',
    'Feature Request',
    'Bug Report',
  ];

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
          'Contact Us',
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
                  // Company Information
                  _buildCompanyInfoSection(),
                  const SizedBox(height: 24),

                  // Important Notice
                  _buildImportantNoticeSection(),
                  const SizedBox(height: 24),

                  // Contact Form
                  _buildContactFormSection(),
                  const SizedBox(height: 24),

                  // Quick Contact Options
                  _buildQuickContactSection(),
                  const SizedBox(height: 24),

                  // Response Time & Requirements
                  _buildResponseInfoSection(),
                  const SizedBox(height: 24),

                  // Professional Partnerships
                  _buildPartnershipSection(),
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
                Icons.support_agent,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact Us',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'We\'re here to help! Get in touch with our support team for any questions or assistance.',
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

  Widget _buildCompanyInfoSection() {
    return _buildSection(
      title: 'Company Information',
      icon: Icons.business,
      iconColor: const Color(0xFF6366F1),
      children: [
        _buildInfoCard('Legal Name', 'KLIKLOKAL', Icons.business_center),
        _buildInfoCard('Brand Name', 'TopPrix.re', Icons.local_offer),
        _buildInfoCard(
            'Address',
            '56 Rue du Général de Gaulle\n97400 Saint-Denis, La Réunion',
            Icons.location_on),
        _buildContactCard('Email', 'contact@topprix.re', Icons.email,
            () => _copyToClipboard('contact@topprix.re')),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 20),
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
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
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

  Widget _buildContactCard(
      String label, String value, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 20),
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
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.copy, color: Color(0xFF6366F1), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportantNoticeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber,
                  color: const Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Important Notice',
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
            'TopPrix.re acts only as a platform for disseminating offers. Published offers are exclusively the responsibility of partner merchants.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF92400E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Product, service, or sales condition questions should be addressed directly to the concerned merchant\n• TopPrix.re does not intervene in transactions, deliveries, or contractual relationships between users and professionals',
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

  Widget _buildContactFormSection() {
    return _buildSection(
      title: 'Send Us a Message',
      icon: Icons.message,
      iconColor: const Color(0xFF10B981),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Inquiry Type Dropdown
              _buildDropdownField(),
              const SizedBox(height: 16),

              // Name and Email Row
              Row(
                children: [
                  Expanded(child: _buildNameField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildEmailField()),
                ],
              ),
              const SizedBox(height: 16),

              // Phone and Subject Row
              Row(
                children: [
                  Expanded(child: _buildPhoneField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSubjectField()),
                ],
              ),
              const SizedBox(height: 16),

              // Merchant field (conditional)
              if (_selectedInquiryType == 'Merchant Complaint' ||
                  _selectedInquiryType == 'Product/Service Issue')
                Column(
                  children: [
                    _buildMerchantField(),
                    const SizedBox(height: 16),
                  ],
                ),

              // Message field
              _buildMessageField(),
              const SizedBox(height: 20),

              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedInquiryType,
      decoration: InputDecoration(
        labelText: 'Type of Inquiry',
        prefixIcon: const Icon(Icons.category, color: Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
      items: _inquiryTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedInquiryType = newValue!;
        });
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Full Name *',
        prefixIcon: const Icon(Icons.person, color: Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email *',
        prefixIcon: const Icon(Icons.email, color: Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        prefixIcon: const Icon(Icons.phone, color: Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      decoration: InputDecoration(
        labelText: 'Subject *',
        prefixIcon: const Icon(Icons.subject, color: Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Subject is required';
        }
        return null;
      },
    );
  }

  Widget _buildMerchantField() {
    return TextFormField(
      controller: _merchantController,
      decoration: InputDecoration(
        labelText: 'Merchant Name / Offer Link',
        prefixIcon: const Icon(Icons.store, color: Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
        helperText: 'Provide the merchant name or link to the specific offer',
      ),
      validator: (value) {
        if ((_selectedInquiryType == 'Merchant Complaint' ||
                _selectedInquiryType == 'Product/Service Issue') &&
            (value == null || value.isEmpty)) {
          return 'Merchant information is required for this type of inquiry';
        }
        return null;
      },
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Message *',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: Icon(Icons.message, color: Color(0xFF10B981)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
        helperText: 'Please provide detailed information about your inquiry',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Message is required';
        }
        if (value.length < 10) {
          return 'Message must be at least 10 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Send Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildQuickContactSection() {
    return _buildSection(
      title: 'Quick Contact Options',
      icon: Icons.quick_contacts_dialer,
      iconColor: const Color(0xFF8B5CF6),
      children: [
        _buildQuickContactOption(
          'General Support',
          'contact@topprix.re',
          'For general questions and support',
          Icons.support,
          const Color(0xFF8B5CF6),
          () => _copyToClipboard('contact@topprix.re'),
        ),
        _buildQuickContactOption(
          'Business Partnerships',
          'direction@topprix.re',
          'For commercial collaborations and partnerships',
          Icons.handshake,
          const Color(0xFF10B981),
          () => _copyToClipboard('direction@topprix.re'),
        ),
      ],
    );
  }

  Widget _buildQuickContactOption(String title, String contact,
      String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 20),
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
                    Text(
                      contact,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.copy, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseInfoSection() {
    return _buildSection(
      title: 'Response Information',
      icon: Icons.schedule,
      iconColor: const Color(0xFFF59E0B),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Response Time: 72 hours maximum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'To guarantee efficient and traceable handling of your request, please provide:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF92400E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Precise subject of your request\n• Merchant name or offer link (if applicable)\n• Your complete contact information\n• Any useful supporting documents (screenshots, etc.)',
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildPartnershipSection() {
    return _buildSection(
      title: 'Professional Partnerships',
      icon: Icons.business_center,
      iconColor: const Color(0xFF3B82F6),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For commercial collaboration, referencing, or local partnership requests:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, color: Color(0xFF3B82F6), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'direction@topprix.re',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Please send a presentation of your activity and your objectives.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E40AF),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copied to clipboard'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Message sent successfully! We\'ll get back to you within 72 hours.'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 3),
        ),
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _messageController.clear();
      _merchantController.clear();
      setState(() {
        _selectedInquiryType = 'General Question';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _merchantController.dispose();
    super.dispose();
  }
}
