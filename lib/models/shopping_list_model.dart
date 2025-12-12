
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListModel {
  final String id;
  final String name;
  final String icon;
  final int color;
  final int itemCount;
  final int boughtCount;
  final String userId;

  ShoppingListModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.userId,
    this.itemCount = 0,
    this.boughtCount = 0,
  });

  // Фабрика: перетворює документ Firebase у наш об'єкт
  factory ShoppingListModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingListModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'asterisk',
      color: data['color'] ?? 0xFF000000,
      userId: data['userId'] ?? '',
      itemCount: data['itemCount'] ?? 0,
      boughtCount: data['boughtCount'] ?? 0,
    );
  }

  // Метод: перетворює об'єкт назад у Map для запису в БД
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'userId': userId,
      'itemCount': itemCount,
      'boughtCount': boughtCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}