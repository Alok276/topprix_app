import 'package:topprix/models/flyer_item_model.dart';

class ShoppingListItemModel {
  final String id;
  final String shoppingListId;
  final String? flyerItemId;
  final FlyerItemModel? flyerItem;
  final String name;
  final int quantity;
  final bool isChecked;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingListItemModel({
    required this.id,
    required this.shoppingListId,
    this.flyerItemId,
    this.flyerItem,
    required this.name,
    required this.quantity,
    required this.isChecked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'],
      shoppingListId: json['shoppingListId'],
      flyerItemId: json['flyerItemId'],
      flyerItem: json['flyerItem'] != null
          ? FlyerItemModel.fromJson(json['flyerItem'])
          : null,
      name: json['name'],
      quantity: json['quantity'],
      isChecked: json['isChecked'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shoppingListId': shoppingListId,
      'flyerItemId': flyerItemId,
      'flyerItem': flyerItem?.toJson(),
      'name': name,
      'quantity': quantity,
      'isChecked': isChecked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ShoppingListItemModel copyWith({
    bool? isChecked,
    int? quantity,
  }) {
    return ShoppingListItemModel(
      id: id,
      shoppingListId: shoppingListId,
      flyerItemId: flyerItemId,
      flyerItem: flyerItem,
      name: name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
