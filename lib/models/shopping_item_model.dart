
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItemModel {
  final String id;
  final String name;
  final String qty;
  final String category;
  final bool bought;

  ShoppingItemModel({
    required this.id,
    required this.name,
    this.qty = '',
    this.category = '',
    this.bought = false,
  });

  factory ShoppingItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      qty: data['qty'] ?? '',
      category: data['category'] ?? '',
      bought: data['bought'] ?? false,
    );
  }
}