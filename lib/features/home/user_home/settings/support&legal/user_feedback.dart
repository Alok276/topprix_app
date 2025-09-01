import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:topprix/theme/app_theme.dart';

// Models
class FeedbackModel {
  final String subject;
  final String message;
  final String category;
  final String userEmail;

  FeedbackModel({
    required this.subject,
    required this.message,
    required this.category,
    required this.userEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'message': message,
      'category': category,
      'userEmail': userEmail,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// API Service
class FeedbackApiService {
  final Dio _dio = Dio();

  FeedbackApiService() {
    _dio.options.baseUrl = 'https://your-api-base-url.com/api';
    _dio.options.connectTimeout = Duration(seconds: 5);
    _dio.options.receiveTimeout = Duration(seconds: 3);
  }

  Future<bool> submitFeedback(FeedbackModel feedback) async {
    try {
      final response = await _dio.post(
        '/feedback',
        data: feedback.toJson(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Future<List<String>> getFeedbackCategories() async {
    try {
      final response = await _dio.get('/feedback/categories');
      return List<String>.from(response.data['categories']);
    } catch (e) {
      // Return default categories if API fails
      return [
        'General',
        'Bug Report',
        'Feature Request',
        'App Performance',
        'User Experience'
      ];
    }
  }
}

// Providers
final feedbackApiProvider = Provider((ref) => FeedbackApiService());

final feedbackCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ref.read(feedbackApiProvider);
  return await apiService.getFeedbackCategories();
});

final feedbackFormProvider =
    StateNotifierProvider<FeedbackFormNotifier, FeedbackFormState>((ref) {
  return FeedbackFormNotifier(ref.read(feedbackApiProvider));
});

// State Classes
class FeedbackFormState {
  final bool isLoading;
  final String? error;
  final bool isSubmitted;

  FeedbackFormState({
    this.isLoading = false,
    this.error,
    this.isSubmitted = false,
  });

  FeedbackFormState copyWith({
    bool? isLoading,
    String? error,
    bool? isSubmitted,
  }) {
    return FeedbackFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class FeedbackFormNotifier extends StateNotifier<FeedbackFormState> {
  final FeedbackApiService _apiService;

  FeedbackFormNotifier(this._apiService) : super(FeedbackFormState());

  Future<void> submitFeedback(FeedbackModel feedback) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _apiService.submitFeedback(feedback);
      if (success) {
        state = state.copyWith(isLoading: false, isSubmitted: true);
      } else {
        state = state.copyWith(
            isLoading: false, error: 'Failed to submit feedback');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetForm() {
    state = FeedbackFormState();
  }
}

// Main Feedback Page
class FeedbackPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCategory = 'General';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      final feedback = FeedbackModel(
        subject: _subjectController.text,
        message: _messageController.text,
        category: _selectedCategory,
        userEmail: _emailController.text,
      );

      ref.read(feedbackFormProvider.notifier).submitFeedback(feedback);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _subjectController.clear();
    _messageController.clear();
    _emailController.clear();
    _selectedCategory = 'General';
    ref.read(feedbackFormProvider.notifier).resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(feedbackFormProvider);
    final categoriesAsync = ref.watch(feedbackCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: formState.isSubmitted
          ? _buildSuccessView()
          : _buildFormView(categoriesAsync, formState),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thank you for your feedback!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We appreciate your input and will review it shortly. Your feedback helps us improve TopPrix.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.surfaceColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Send Another Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(
      AsyncValue<List<String>> categoriesAsync, FeedbackFormState formState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.feedback_outlined,
                      size: 48, color: AppTheme.surfaceColor),
                  SizedBox(height: 16),
                  Text(
                    'We\'d love to hear from you!',
                    style: TextStyle(
                      color: AppTheme.surfaceColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your feedback helps us improve TopPrix and provide better deals for everyone.',
                    style: TextStyle(
                      color: AppTheme.surfaceColor,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Fields Container
            Container(
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
                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Category Dropdown
                  categoriesAsync.when(
                    data: (categories) => _buildDropdownField(categories),
                    loading: () => _buildDropdownField(
                        ['General', 'Bug Report', 'Feature Request']),
                    error: (_, __) => _buildDropdownField(
                        ['General', 'Bug Report', 'Feature Request']),
                  ),

                  const SizedBox(height: 20),

                  // Subject Field
                  _buildTextField(
                    controller: _subjectController,
                    label: 'Subject',
                    icon: Icons.subject_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject';
                      }
                      if (value.length < 5) {
                        return 'Subject must be at least 5 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Message Field
                  _buildTextField(
                    controller: _messageController,
                    label: 'Your Message',
                    icon: Icons.message_outlined,
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      if (value.length < 20) {
                        return 'Message must be at least 20 characters long';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Error Message
            if (formState.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formState.error!,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formState.isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.surfaceColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  disabledBackgroundColor:
                      AppTheme.primaryColor.withOpacity(0.6),
                ),
                child: formState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.surfaceColor),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Submit Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select Category',
            prefixIcon: const Icon(Icons.category_outlined,
                color: AppTheme.primaryColor, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }
}
