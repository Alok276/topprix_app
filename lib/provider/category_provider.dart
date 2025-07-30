// lib/provider/category_provider.dart - Fixed Version

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topprix/services/category_service.dart';
import '../models/category_model.dart';

// Category Service Provider
final categoryServiceProvider = Provider((ref) => CategoryService());

// Categories Provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  final response = await categoryService.getAllCategories();
  return response.success ? response.data ?? [] : [];
});

// Individual Category Provider
final categoryDetailProvider =
    FutureProvider.family<CategoryModel?, String>((ref, categoryId) async {
  final categoryService = ref.watch(categoryServiceProvider);
  final response = await categoryService.getCategoryDetail(categoryId);
  return response.success ? response.data : null;
});

// Categories by Store Provider
final categoriesByStoreProvider =
    FutureProvider.family<List<CategoryModel>, String>((ref, storeId) async {
  final categoryService = ref.watch(categoryServiceProvider);
  final response = await categoryService.getCategoriesByStore(storeId);
  return response.success ? response.data ?? [] : [];
});

// Featured Categories Provider
final featuredCategoriesProvider =
    FutureProvider<List<CategoryModel>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  final response = await categoryService.getFeaturedCategories();
  return response.success ? response.data ?? [] : [];
});

// Category Search Provider
final categorySearchProvider =
    FutureProvider.family<List<CategoryModel>, String>((ref, query) async {
  final categoryService = ref.watch(categoryServiceProvider);
  final response = await categoryService.searchCategories(query);
  return response.success ? response.data ?? [] : [];
});
