// // providers/category_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:topprix/features/home/retailer_home/categories/category_model.dart';
// import 'package:topprix/features/home/retailer_home/categories/category_service.dart';

// enum CategoryLoadingState {
//   idle,
//   loading,
//   loaded,
//   error,
// }

// // State classes
// class CategoryState {
//   final List<Category> categories;
//   final CategoryLoadingState loadingState;
//   final String? errorMessage;
//   final String? successMessage;
//   final int currentPage;
//   final bool hasMoreData;

//   const CategoryState({
//     this.categories = const [],
//     this.loadingState = CategoryLoadingState.idle,
//     this.errorMessage,
//     this.successMessage,
//     this.currentPage = 1,
//     this.hasMoreData = true,
//   });

//   CategoryState copyWith({
//     List<Category>? categories,
//     CategoryLoadingState? loadingState,
//     String? errorMessage,
//     String? successMessage,
//     int? currentPage,
//     bool? hasMoreData,
//   }) {
//     return CategoryState(
//       categories: categories ?? this.categories,
//       loadingState: loadingState ?? this.loadingState,
//       errorMessage: errorMessage,
//       successMessage: successMessage,
//       currentPage: currentPage ?? this.currentPage,
//       hasMoreData: hasMoreData ?? this.hasMoreData,
//     );
//   }
// }

// class SearchState {
//   final String query;
//   final List<Category> results;
//   final bool isSearching;
//   final CategoryLoadingState loadingState;

//   const SearchState({
//     this.query = '',
//     this.results = const [],
//     this.isSearching = false,
//     this.loadingState = CategoryLoadingState.idle,
//   });

//   SearchState copyWith({
//     String? query,
//     List<Category>? results,
//     bool? isSearching,
//     CategoryLoadingState? loadingState,
//   }) {
//     return SearchState(
//       query: query ?? this.query,
//       results: results ?? this.results,
//       isSearching: isSearching ?? this.isSearching,
//       loadingState: loadingState ?? this.loadingState,
//     );
//   }
// }

// // Service provider
// final categoryServiceProvider = Provider<CategoryService>((ref) {
//   return CategoryService();
// });

// // Auth token provider
// final authTokenProvider = StateProvider<String?>((ref) => null);

// // Category state provider
// final categoryStateProvider =
//     StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
//   final service = ref.watch(categoryServiceProvider);
//   final authToken = ref.watch(authTokenProvider);

//   if (authToken != null) {
//     service.setAuthToken(authToken);
//   }

//   return CategoryNotifier(service);
// });

// // Search state provider
// final searchStateProvider =
//     StateNotifierProvider<SearchNotifier, SearchState>((ref) {
//   final service = ref.watch(categoryServiceProvider);
//   final authToken = ref.watch(authTokenProvider);

//   if (authToken != null) {
//     service.setAuthToken(authToken);
//   }

//   return SearchNotifier(service);
// });

// // Selected category provider
// final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

// // Category notifier
// class CategoryNotifier extends StateNotifier<CategoryState> {
//   final CategoryService _categoryService;
//   static const int _itemsPerPage = 20;

//   CategoryNotifier(this._categoryService) : super(const CategoryState());

//   // Fetch all categories
//   Future<void> fetchCategories({
//     bool refresh = false,
//     String? search,
//     bool? activeOnly,
//     String? parentId,
//   }) async {
//     if (refresh) {
//       state = state.copyWith(currentPage: 1, hasMoreData: true);
//     }

//     if (state.loadingState == CategoryLoadingState.loading && !refresh) return;

//     state = state.copyWith(
//       loadingState: CategoryLoadingState.loading,
//       categories: refresh ? [] : state.categories,
//     );

//     try {
//       final response = await _categoryService.getAllCategories(
//         page: state.currentPage,
//         limit: _itemsPerPage,
//         search: search,
//         activeOnly: activeOnly,
//         parentId: parentId,
//       );

//       if (response.success && response.data != null) {
//         final newCategories = state.currentPage == 1
//             ? response.data!
//             : [...state.categories, ...response.data!];

//         state = state.copyWith(
//           categories: newCategories,
//           loadingState: CategoryLoadingState.loaded,
//           hasMoreData: response.data!.length == _itemsPerPage,
//           currentPage: state.currentPage + 1,
//           successMessage: response.message ?? 'Categories loaded successfully',
//           errorMessage: null,
//         );
//       } else {
//         state = state.copyWith(
//           loadingState: CategoryLoadingState.error,
//           errorMessage: response.message ?? 'Failed to load categories',
//           successMessage: null,
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         loadingState: CategoryLoadingState.error,
//         errorMessage: 'Error loading categories: ${e.toString()}',
//         successMessage: null,
//       );
//     }
//   }

//   // Load more categories (pagination)
//   Future<void> loadMoreCategories() async {
//     if (!state.hasMoreData ||
//         state.loadingState == CategoryLoadingState.loading) return;
//     await fetchCategories();
//   }

//   // Refresh categories
//   Future<void> refreshCategories() async {
//     await fetchCategories(refresh: true);
//   }

//   // Get category by ID
//   Future<Category?> getCategoryById(String id) async {
//     state = state.copyWith(loadingState: CategoryLoadingState.loading);

//     try {
//       final response = await _categoryService.getCategoryById(id);

//       if (response.success && response.data != null) {
//         state = state.copyWith(
//           loadingState: CategoryLoadingState.loaded,
//           successMessage: response.message ?? 'Category loaded successfully',
//           errorMessage: null,
//         );
//         return response.data;
//       } else {
//         state = state.copyWith(
//           loadingState: CategoryLoadingState.error,
//           errorMessage: response.message ?? 'Category not found',
//           successMessage: null,
//         );
//         return null;
//       }
//     } catch (e) {
//       state = state.copyWith(
//         loadingState: CategoryLoadingState.error,
//         errorMessage: 'Error loading category: ${e.toString()}',
//         successMessage: null,
//       );
//       return null;
//     }
//   }

//   // Create category
//   Future<bool> createCategory(Category category) async {
//     try {
//       final response = await _categoryService.createCategory(category);

//       if (response.success && response.data != null) {
//         state = state.copyWith(
//           categories: [response.data!, ...state.categories],
//           successMessage: response.message ?? 'Category created successfully',
//           errorMessage: null,
//         );
//         return true;
//       } else {
//         state = state.copyWith(
//           errorMessage: response.message ?? 'Failed to create category',
//           successMessage: null,
//         );
//         return false;
//       }
//     } catch (e) {
//       state = state.copyWith(
//         errorMessage: 'Error creating category: ${e.toString()}',
//         successMessage: null,
//       );
//       return false;
//     }
//   }

//   // Update category
//   Future<bool> updateCategory(String id, Category category) async {
//     try {
//       final response = await _categoryService.updateCategory(id, category);

//       if (response.success && response.data != null) {
//         final updatedCategories = state.categories.map((cat) {
//           return cat.id == id ? response.data! : cat;
//         }).toList();

//         state = state.copyWith(
//           categories: updatedCategories,
//           successMessage: response.message ?? 'Category updated successfully',
//           errorMessage: null,
//         );
//         return true;
//       } else {
//         state = state.copyWith(
//           errorMessage: response.message ?? 'Failed to update category',
//           successMessage: null,
//         );
//         return false;
//       }
//     } catch (e) {
//       state = state.copyWith(
//         errorMessage: 'Error updating category: ${e.toString()}',
//         successMessage: null,
//       );
//       return false;
//     }
//   }

//   // Delete category
//   Future<bool> deleteCategory(String id) async {
//     try {
//       final response = await _categoryService.deleteCategory(id);

//       if (response.success) {
//         final updatedCategories =
//             state.categories.where((cat) => cat.id != id).toList();

//         state = state.copyWith(
//           categories: updatedCategories,
//           successMessage: response.message ?? 'Category deleted successfully',
//           errorMessage: null,
//         );
//         return true;
//       } else {
//         state = state.copyWith(
//           errorMessage: response.message ?? 'Failed to delete category',
//           successMessage: null,
//         );
//         return false;
//       }
//     } catch (e) {
//       state = state.copyWith(
//         errorMessage: 'Error deleting category: ${e.toString()}',
//         successMessage: null,
//       );
//       return false;
//     }
//   }

//   // Toggle category status
//   Future<bool> toggleCategoryStatus(String id) async {
//     try {
//       final response = await _categoryService.toggleCategoryStatus(id);

//       if (response.success && response.data != null) {
//         final updatedCategories = state.categories.map((cat) {
//           return cat.id == id ? response.data! : cat;
//         }).toList();

//         state = state.copyWith(
//           categories: updatedCategories,
//           successMessage:
//               response.message ?? 'Category status updated successfully',
//           errorMessage: null,
//         );
//         return true;
//       } else {
//         state = state.copyWith(
//           errorMessage: response.message ?? 'Failed to update category status',
//           successMessage: null,
//         );
//         return false;
//       }
//     } catch (e) {
//       state = state.copyWith(
//         errorMessage: 'Error updating status: ${e.toString()}',
//         successMessage: null,
//       );
//       return false;
//     }
//   }

//   // Bulk delete categories
//   Future<bool> bulkDeleteCategories(List<String> ids) async {
//     try {
//       final response = await _categoryService.bulkDeleteCategories(ids);

//       if (response.success) {
//         final updatedCategories =
//             state.categories.where((cat) => !ids.contains(cat.id)).toList();

//         state = state.copyWith(
//           categories: updatedCategories,
//           successMessage: response.message ?? 'Categories deleted successfully',
//           errorMessage: null,
//         );
//         return true;
//       } else {
//         state = state.copyWith(
//           errorMessage: response.message ?? 'Failed to delete categories',
//           successMessage: null,
//         );
//         return false;
//       }
//     } catch (e) {
//       state = state.copyWith(
//         errorMessage: 'Error deleting categories: ${e.toString()}',
//         successMessage: null,
//       );
//       return false;
//     }
//   }

//   // Get subcategories
//   Future<List<Category>> getSubcategories(String parentId) async {
//     try {
//       final response = await _categoryService.getSubcategories(parentId);

//       if (response.success && response.data != null) {
//         return response.data!;
//       } else {
//         state = state.copyWith(
//             errorMessage: response.message ?? 'Failed to load subcategories');
//         return [];
//       }
//     } catch (e) {
//       state = state.copyWith(
//           errorMessage: 'Error loading subcategories: ${e.toString()}');
//       return [];
//     }
//   }

//   // Clear messages
//   void clearMessages() {
//     state = state.copyWith(errorMessage: null, successMessage: null);
//   }

//   // Clear error
//   void clearError() {
//     state = state.copyWith(errorMessage: null);
//   }

//   // Reset state
//   void reset() {
//     state = const CategoryState();
//   }
// }

// // Search notifier
// class SearchNotifier extends StateNotifier<SearchState> {
//   final CategoryService _categoryService;

//   SearchNotifier(this._categoryService) : super(const SearchState());

//   // Search categories
//   Future<void> searchCategories(String query) async {
//     state = state.copyWith(
//       query: query,
//       isSearching: query.isNotEmpty,
//     );

//     if (query.isEmpty) {
//       state =
//           state.copyWith(results: [], loadingState: CategoryLoadingState.idle);
//       return;
//     }

//     state = state.copyWith(loadingState: CategoryLoadingState.loading);

//     try {
//       final response = await _categoryService.searchCategories(query);

//       if (response.success && response.data != null) {
//         state = state.copyWith(
//           results: response.data!,
//           loadingState: CategoryLoadingState.loaded,
//         );
//       } else {
//         state = state.copyWith(
//           loadingState: CategoryLoadingState.error,
//           results: [],
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         loadingState: CategoryLoadingState.error,
//         results: [],
//       );
//     }
//   }

//   // Clear search
//   void clearSearch() {
//     state = const SearchState();
//   }
// }

// // Computed providers
// final activeCategoriesProvider = Provider<List<Category>>((ref) {
//   final categories = ref.watch(categoryStateProvider).categories;
//   return categories.where((category) => category.isActive).toList();
// });

// final inactiveCategoriesProvider = Provider<List<Category>>((ref) {
//   final categories = ref.watch(categoryStateProvider).categories;
//   return categories.where((category) => !category.isActive).toList();
// });

// final parentCategoriesProvider = Provider<List<Category>>((ref) {
//   final categories = ref.watch(categoryStateProvider).categories;
//   return categories.where((category) => category.parentId == null).toList();
// });

// // Provider to get subcategories for a specific parent
// final subcategoriesProvider =
//     Provider.family<List<Category>, String?>((ref, parentId) {
//   final categories = ref.watch(categoryStateProvider).categories;
//   return categories.where((category) => category.parentId == parentId).toList();
// });

// // Provider to get category by ID
// final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
//   final categories = ref.watch(categoryStateProvider).categories;
//   try {
//     return categories.firstWhere((category) => category.id == id);
//   } catch (e) {
//     return null;
//   }
// });

// // Error message provider
// final categoryErrorProvider = Provider<String?>((ref) {
//   return ref.watch(categoryStateProvider).errorMessage;
// });

// // Success message provider
// final categorySuccessProvider = Provider<String?>((ref) {
//   return ref.watch(categoryStateProvider).successMessage;
// });

// // Loading state provider
// final categoryLoadingProvider = Provider<CategoryLoadingState>((ref) {
//   return ref.watch(categoryStateProvider).loadingState;
// });
