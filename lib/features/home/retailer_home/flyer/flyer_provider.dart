// // lib/features/flyers/providers/flyers_providers.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:topprix/features/auth/service/auth_service.dart';
// import 'package:topprix/features/home/retailer_home/flyer/flyer_models.dart';
// import 'package:topprix/features/home/retailer_home/flyer/services/flyer_service.dart';
// import 'package:topprix/features/home/retailer_home/flyer/services/payment_service.dart';
// import 'package:topprix/provider/dio_provider.dart';

// // Services Providers
// final flyersServiceProvider = Provider<FlyersService>((ref) {
//   final dio = ref.read(dioProvider);
//   final service = FlyersService(dio);

//   ref.onDispose(() {
//     service.dispose();
//   });

//   return service;
// });

// final paymentServiceProvider = Provider<PaymentService>((ref) {
//   final dio = ref.read(dioProvider);
//   final service = PaymentService(dio);

//   ref.onDispose(() {
//     service.dispose();
//   });

//   return service;
// });

// // State Providers for UI Management
// final createFlyerLoadingProvider = StateProvider<bool>((ref) => false);
// final uploadImageLoadingProvider = StateProvider<bool>((ref) => false);
// final paymentLoadingProvider = StateProvider<bool>((ref) => false);

// // Create Flyer Form State
// final createFlyerFormProvider =
//     StateNotifierProvider<CreateFlyerFormNotifier, CreateFlyerFormState>((ref) {
//   return CreateFlyerFormNotifier();
// });

// class CreateFlyerFormState {
//   final String title;
//   final String? selectedStoreId;
//   final String? imageUrl;
//   final DateTime? startDate;
//   final DateTime? endDate;
//   final bool isSponsored;
//   final List<String> selectedCategoryIds;
//   final bool isPremium;
//   final String? error;

//   CreateFlyerFormState({
//     this.title = '',
//     this.selectedStoreId,
//     this.imageUrl,
//     this.startDate,
//     this.endDate,
//     this.isSponsored = false,
//     this.selectedCategoryIds = const [],
//     this.isPremium = false,
//     this.error,
//   });

//   CreateFlyerFormState copyWith({
//     String? title,
//     String? selectedStoreId,
//     String? imageUrl,
//     DateTime? startDate,
//     DateTime? endDate,
//     bool? isSponsored,
//     List<String>? selectedCategoryIds,
//     bool? isPremium,
//     String? error,
//   }) {
//     return CreateFlyerFormState(
//       title: title ?? this.title,
//       selectedStoreId: selectedStoreId ?? this.selectedStoreId,
//       imageUrl: imageUrl ?? this.imageUrl,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       isSponsored: isSponsored ?? this.isSponsored,
//       selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
//       isPremium: isPremium ?? this.isPremium,
//       error: error,
//     );
//   }

//   bool get isValid {
//     return title.isNotEmpty &&
//         selectedStoreId != null &&
//         imageUrl != null &&
//         startDate != null &&
//         endDate != null &&
//         selectedCategoryIds.isNotEmpty;
//   }
// }

// class CreateFlyerFormNotifier extends StateNotifier<CreateFlyerFormState> {
//   CreateFlyerFormNotifier() : super(CreateFlyerFormState());

//   void updateTitle(String title) {
//     state = state.copyWith(title: title, error: null);
//   }

//   void updateStoreId(String storeId) {
//     state = state.copyWith(selectedStoreId: storeId, error: null);
//   }

//   void updateImageUrl(String imageUrl) {
//     state = state.copyWith(imageUrl: imageUrl, error: null);
//   }

//   void updateStartDate(DateTime startDate) {
//     state = state.copyWith(startDate: startDate, error: null);
//   }

//   void updateEndDate(DateTime endDate) {
//     state = state.copyWith(endDate: endDate, error: null);
//   }

//   void toggleSponsored() {
//     state = state.copyWith(isSponsored: !state.isSponsored, error: null);
//   }

//   void togglePremium() {
//     state = state.copyWith(isPremium: !state.isPremium, error: null);
//   }

//   void updateCategoryIds(List<String> categoryIds) {
//     state = state.copyWith(selectedCategoryIds: categoryIds, error: null);
//   }

//   void addCategoryId(String categoryId) {
//     final currentIds = List<String>.from(state.selectedCategoryIds);
//     if (!currentIds.contains(categoryId)) {
//       currentIds.add(categoryId);
//       state = state.copyWith(selectedCategoryIds: currentIds, error: null);
//     }
//   }

//   void removeCategoryId(String categoryId) {
//     final currentIds = List<String>.from(state.selectedCategoryIds);
//     currentIds.remove(categoryId);
//     state = state.copyWith(selectedCategoryIds: currentIds, error: null);
//   }

//   void setError(String error) {
//     state = state.copyWith(error: error);
//   }

//   void clearError() {
//     state = state.copyWith(error: null);
//   }

//   void reset() {
//     state = CreateFlyerFormState();
//   }
// }

// // Flyers List Providers
// final flyersProvider = FutureProvider.autoDispose<List<Flyer>>((ref) async {
//   final service = ref.read(flyersServiceProvider);
//   final response = await service.getFlyers();
//   return response.flyers;
// });

// final activeFlyersProvider =
//     FutureProvider.autoDispose<List<Flyer>>((ref) async {
//   final service = ref.read(flyersServiceProvider);
//   return await service.getActiveFlyers();
// });

// final sponsoredFlyersProvider =
//     FutureProvider.autoDispose<List<Flyer>>((ref) async {
//   final service = ref.read(flyersServiceProvider);
//   return await service.getSponsoredFlyers();
// });

// // Flyer by ID Provider
// final flyerByIdProvider =
//     FutureProvider.autoDispose.family<Flyer?, String>((ref, flyerId) async {
//   final service = ref.read(flyersServiceProvider);
//   return await service.getFlyerById(flyerId);
// });

// // Store Flyers Provider
// final storeFlyersProvider = FutureProvider.autoDispose
//     .family<List<Flyer>, String>((ref, storeId) async {
//   final service = ref.read(flyersServiceProvider);
//   return await service.getFlyersByStore(storeId);
// });

// // User's Saved Flyers Provider
// final savedFlyersProvider =
//     FutureProvider.autoDispose<List<Flyer>>((ref) async {
//   final service = ref.read(flyersServiceProvider);
//   final authState = ref.read(topPrixAuthProvider);

//   if (authState.backendUser == null) {
//     return [];
//   }

//   return await service.getSavedFlyers(authState.backendUser!.id);
// });

// // Search Flyers Provider
// final searchFlyersProvider =
//     FutureProvider.autoDispose.family<List<Flyer>, String>((ref, query) async {
//   if (query.trim().isEmpty) return [];

//   final service = ref.read(flyersServiceProvider);
//   return await service.searchFlyers(query);
// });

// // Flyer Actions Provider
// final flyerActionsProvider = Provider<FlyerActions>((ref) {
//   return FlyerActions(ref);
// });

// class FlyerActions {
//   final Ref _ref;

//   FlyerActions(this._ref);

//   Future<CreateFlyerResponse?> createFlyer() async {
//     final formState = _ref.read(createFlyerFormProvider);
//     final service = _ref.read(flyersServiceProvider);
//     final loadingNotifier = _ref.read(createFlyerLoadingProvider.notifier);

//     if (!formState.isValid) {
//       _ref
//           .read(createFlyerFormProvider.notifier)
//           .setError('Please fill all required fields');
//       return null;
//     }

//     try {
//       loadingNotifier.state = true;

//       final request = CreateFlyerRequest(
//         title: formState.title,
//         storeId: formState.selectedStoreId!,
//         imageUrl: formState.imageUrl!,
//         startDate: formState.startDate!,
//         endDate: formState.endDate!,
//         // isSponsored: formState.isSponsored,
//         categoryIds: formState.selectedCategoryIds,
//         //  isPremium: formState.isPremium,
//       );

//       final result = await service.createFlyer(request);

//       if (result != null) {
//         // Reset form on success
//         _ref.read(createFlyerFormProvider.notifier).reset();
//         // Invalidate flyers list to refresh
//         _ref.invalidate(flyersProvider);
//         _ref.invalidate(activeFlyersProvider);
//       } else {
//         _ref
//             .read(createFlyerFormProvider.notifier)
//             .setError('Failed to create flyer');
//       }

//       return result;
//     } catch (e) {
//       _ref.read(createFlyerFormProvider.notifier).setError('Error: $e');
//       return null;
//     } finally {
//       loadingNotifier.state = false;
//     }
//   }

//   Future<bool> saveFlyer(String flyerId) async {
//     final service = _ref.read(flyersServiceProvider);
//     final authState = _ref.read(topPrixAuthProvider);

//     if (authState.backendUser == null) return false;

//     try {
//       final request = SaveFlyerRequest(
//         userId: authState.backendUser!.id,
//         flyerId: flyerId,
//       );

//       final success = await service.saveFlyer(request);

//       if (success) {
//         // Refresh saved flyers list
//         _ref.invalidate(savedFlyersProvider);
//       }

//       return success;
//     } catch (e) {
//       print('Error saving flyer: $e');
//       return false;
//     }
//   }

//   Future<bool> deleteFlyer(String flyerId) async {
//     final service = _ref.read(flyersServiceProvider);

//     try {
//       final success = await service.deleteFlyer(flyerId);

//       if (success) {
//         // Refresh all flyer lists
//         _ref.invalidate(flyersProvider);
//         _ref.invalidate(activeFlyersProvider);
//         _ref.invalidate(savedFlyersProvider);
//       }

//       return success;
//     } catch (e) {
//       print('Error deleting flyer: $e');
//       return false;
//     }
//   }

//   Future<String?> uploadImage(dynamic imageFile) async {
//     final service = _ref.read(flyersServiceProvider);
//     final loadingNotifier = _ref.read(uploadImageLoadingProvider.notifier);

//     try {
//       loadingNotifier.state = true;
//       return await service.uploadFlyerImage(imageFile);
//     } catch (e) {
//       print('Error uploading image: $e');
//       return null;
//     } finally {
//       loadingNotifier.state = false;
//     }
//   }

//   Future<PaymentIntent?> createPaymentIntent({
//     required String flyerId,
//     required double amount,
//     String currency = 'eur',
//   }) async {
//     final paymentService = _ref.read(paymentServiceProvider);
//     final authState = _ref.read(topPrixAuthProvider);
//     final loadingNotifier = _ref.read(paymentLoadingProvider.notifier);

//     if (authState.backendUser == null) return null;

//     try {
//       loadingNotifier.state = true;

//       return await paymentService.createFlyerPaymentIntent(
//         userId: authState.backendUser!.id,
//         flyerId: flyerId,
//         amount: amount,
//         currency: currency,
//       );
//     } catch (e) {
//       print('Error creating payment intent: $e');
//       return null;
//     } finally {
//       loadingNotifier.state = false;
//     }
//   }

//   Future<bool> handlePaymentSuccess(String paymentIntentId) async {
//     final paymentService = _ref.read(paymentServiceProvider);
//     final loadingNotifier = _ref.read(paymentLoadingProvider.notifier);

//     try {
//       loadingNotifier.state = true;

//       final request = PaymentSuccessRequest(paymentIntentId: paymentIntentId);
//       final success = await paymentService.handlePaymentSuccess(request);

//       if (success) {
//         // Refresh flyers to show updated payment status
//         _ref.invalidate(flyersProvider);
//         _ref.invalidate(activeFlyersProvider);
//       }

//       return success;
//     } catch (e) {
//       print('Error handling payment success: $e');
//       return false;
//     } finally {
//       loadingNotifier.state = false;
//     }
//   }
// }

// // Selected categories for filter provider
// final selectedCategoriesProvider = StateProvider<List<String>>((ref) => []);

// // Filtered flyers provider
// final filteredFlyersProvider =
//     FutureProvider.autoDispose<List<Flyer>>((ref) async {
//   final selectedCategories = ref.watch(selectedCategoriesProvider);
//   final service = ref.read(flyersServiceProvider);

//   if (selectedCategories.isEmpty) {
//     final response = await service.getFlyers();
//     return response.flyers;
//   }

//   // For simplicity, get flyers for first selected category
//   // In a real app, you might want to implement a more complex filtering system
//   final response =
//       await service.getFlyers(categoryId: selectedCategories.first);
//   return response.flyers;
// });
