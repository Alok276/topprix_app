import 'package:topprix/models/shopping_list_item_model.dart';

class ShoppingListModel {
  final String id;
  final String title;
  final String userId;
  final List<ShoppingListItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingListModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'],
      title: json['title'],
      userId: json['userId'],
      items: (json['items'] as List?)
              ?.map((item) => ShoppingListItemModel.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  int get totalItems => items.length;
  int get checkedItems => items.where((item) => item.isChecked).length;
  int get uncheckedItems => items.where((item) => !item.isChecked).length;
  double get completionPercentage =>
      totalItems > 0 ? (checkedItems / totalItems) * 100 : 0;
}
