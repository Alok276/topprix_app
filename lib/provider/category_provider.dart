import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';

// Categories Provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  ProviderListenable categoryServiceProvider;
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
