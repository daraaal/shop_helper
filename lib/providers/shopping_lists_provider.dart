
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_list_model.dart'; 

class ShoppingListsProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<ShoppingListModel> _shoppingLists = []; 

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ShoppingListModel> get shoppingLists => _shoppingLists;

  Future<void> fetchLists() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('shopping_lists')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _shoppingLists = snapshot.docs
          .map((doc) => ShoppingListModel.fromSnapshot(doc))
          .toList();
          
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Не вдалося завантажити списки.';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addShoppingList(Map<String, dynamic> data, int colorValue) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    final newList = ShoppingListModel(
      id: '', 
      name: data['name'],
      icon: data['icon'],
      color: colorValue,
      userId: userId,
    );

    await FirebaseFirestore.instance.collection('shopping_lists').add(newList.toMap());
    await fetchLists();
  }

  Future<void> updateShoppingList(String listId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('shopping_lists').doc(listId).update(data);
    await fetchLists();
  }

  Future<void> deleteShoppingList(String listId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('shopping_lists').doc(listId);
      
      final itemsSnapshot = await docRef.collection('items').get();
      if (itemsSnapshot.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in itemsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      
      await docRef.delete();
      await fetchLists();
    } catch (e) {
      print("Помилка видалення: $e");
    }
  }

  Future<void> refreshSingleList(String listId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('shopping_lists').doc(listId).get();
      if (doc.exists) {
        final updatedList = ShoppingListModel.fromSnapshot(doc);
        final index = _shoppingLists.indexWhere((list) => list.id == listId);
        if (index != -1) {
          _shoppingLists[index] = updatedList;
          notifyListeners(); // Повідомляємо слухачів про зміну
        }
      }
    } catch (e) {
      print("Помилка оновлення одного списку: $e");
    }
  }
}

/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingListsProvider with ChangeNotifier {
  bool _isLoading = true;
  String? _errorMessage;
  List<QueryDocumentSnapshot> _shoppingLists = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QueryDocumentSnapshot> get shoppingLists => _shoppingLists;

  Future<void> fetchLists() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _errorMessage = "Користувач не автентифікований.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('shopping_lists')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _shoppingLists = snapshot.docs;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Не вдалося завантажити списки.';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addShoppingList(Map<String, dynamic> data, int colorValue) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    await FirebaseFirestore.instance.collection('shopping_lists').add({
      ...data,
      'createdAt': Timestamp.now(),
      'userId': userId,
      'itemCount': 0,
      'boughtCount': 0,
      'color': colorValue,
    });
    
    await fetchLists();
  }

  Future<void> updateShoppingList(QueryDocumentSnapshot? listDoc, Map<String, dynamic> data) async {
    if (listDoc == null) return;
    await listDoc.reference.update(data);
    await fetchLists();
  }

  Future<void> deleteShoppingList(QueryDocumentSnapshot listDoc) async {
    try {
      final itemsSnapshot = await listDoc.reference.collection('items').get();
      if (itemsSnapshot.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in itemsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      await listDoc.reference.delete();
      await fetchLists();
    } catch (e) {
      print("Помилка видалення: $e");
      // Тут можна показати SnackBar через глобальний ключ або іншим способом
    }
  }
}
*/