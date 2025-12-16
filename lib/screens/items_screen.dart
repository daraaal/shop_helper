
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_helper_app/core/widgets/custom_text_field.dart';
import '../core/app_colors.dart';

class ItemsScreen extends StatefulWidget {
  final String listId;
  final String listName;
  final String listIconName; 
  const ItemsScreen({
    super.key,
    required this.listId,
    required this.listName,
    this.listIconName = 'carrot', 
  });

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  // Функція для оновлення статусу товару
  void _toggleItemStatus(DocumentSnapshot itemDoc) {
    final itemData = itemDoc.data() as Map<String, dynamic>;
    final isBought = itemData['bought'] as bool;
    itemDoc.reference.update({'bought': !isBought});
    FirebaseFirestore.instance.collection('shopping_lists').doc(widget.listId).update({
      'boughtCount': FieldValue.increment(!isBought ? 1 : -1)
    });
  }

  // Функція для видалення товару
  void _deleteItem(String itemId) {
    final listRef = FirebaseFirestore.instance.collection('shopping_lists').doc(widget.listId);
    listRef.collection('items').doc(itemId).get().then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final wasBought = data['bought'] as bool;
        doc.reference.delete();
        final updateData = {'itemCount': FieldValue.increment(-1)};
        if (wasBought) {
          updateData['boughtCount'] = FieldValue.increment(-1);
        }
        listRef.update(updateData);
      }
    });
  }

  // ЄДИНЕ МОДАЛЬНЕ ВІКНО для додавання та редагування
  void _showItemDialog({DocumentSnapshot? itemDoc}) {
    final bool isEditing = itemDoc != null;
    final itemData = isEditing ? itemDoc.data() as Map<String, dynamic> : null;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: isEditing ? itemData!['name'] : '');
    final qtyController = TextEditingController(text: isEditing ? itemData!['qty'] : '');
    final categoryController = TextEditingController(text: isEditing ? itemData!['category'] ?? '' : '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Редагувати товар' : 'Додати новий товар'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Назва товару',
                    hintText: 'Наприклад, молоко',
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Назва не може бути порожньою' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: qtyController,
                    labelText: 'Кількість (опціонально)',
                    hintText: 'Наприклад, 2л',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: categoryController,
                    labelText: 'Категорія (опціонально)',
                    hintText: 'Наприклад, Продукти',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Скасувати')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'name': nameController.text.trim(),
                    'qty': qtyController.text.trim(),
                    'category': categoryController.text.trim(),
                  };
                  if (isEditing) {
                    itemDoc.reference.update(data);
                  } else {
                    _saveNewItem(data);
                  }
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(isEditing ? 'Зберегти' : 'Додати'),
            ),
          ],
        );
      },
    );
  }

  // Функція для збереження НОВОГО товару
  void _saveNewItem(Map<String, dynamic> data) {
    final listRef = FirebaseFirestore.instance.collection('shopping_lists').doc(widget.listId);
    listRef.collection('items').add({
      ...data, // Додаємо name, qty, category
      'bought': false,
      'createdAt': Timestamp.now(),
    }).then((_) => listRef.update({'itemCount': FieldValue.increment(1)}));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(widget.listName),
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
                .collection('shopping_lists')
                .doc(widget.listId)
                .collection('items')
                .orderBy('createdAt')
                .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const _EmptyStateWidget();
              }
              
              final items = snapshot.data!.docs;
              final activeItems = items.where((doc) => !(doc.data() as Map<String, dynamic>)['bought']).toList();
              final completedItems = items.where((doc) => (doc.data() as Map<String, dynamic>)['bought']).toList();


            // Картка буде використовувати стиль з CardTheme
            return Card(
              margin: const EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                  children: [
                    if (activeItems.isNotEmpty)
                    ...activeItems.map((item) => _buildItemTile(item)).toList(),

                    if (completedItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'Вже в кошику (${completedItems.length})',
                          style: TextStyle(
                            color: AppColors.darkGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    if (completedItems.isNotEmpty)
                    ...completedItems.map((item) => _buildItemTile(item)).toList(),
                  ],
              ),
            );
          },
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showItemDialog(),
      child: const Icon(Icons.add),
    ),
    );
  }

  // ОНОВЛЕНИЙ ВІДЖЕТ ТОВАРУ з кнопками
  Widget _buildItemTile(DocumentSnapshot itemDoc) {
    final itemData = itemDoc.data() as Map<String, dynamic>;
    final isBought = itemData['bought'] as bool;
    final qty = itemData['qty'] as String?;
    final category = itemData['category'] as String?;

    return ListTile(
      onTap: () => _toggleItemStatus(itemDoc),
      contentPadding: const EdgeInsets.only(left: 8, right: 0, top: 2, bottom: 2),
      leading: Checkbox(
        value: isBought,
        onChanged: (value) => _toggleItemStatus(itemDoc),
        activeColor: AppColors.darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: Text(
        itemData['name'],
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: isBought ? AppColors.textLight : AppColors.textDark,
          decoration: isBought ? TextDecoration.lineThrough : null,
          decorationColor: AppColors.textLight,
        ),
      ),
      subtitle: (qty != null && qty.isNotEmpty) || (category != null && category.isNotEmpty)
        ? Text(
            "${qty ?? ''}${(qty != null && qty.isNotEmpty && category != null && category.isNotEmpty) ? '  •  ' : ''}${category ?? ''}",
            style: const TextStyle(color: AppColors.textLight),
          )
        : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined, color: AppColors.textLight, size: 22),
            onPressed: () => _showItemDialog(itemDoc: itemDoc), // Виклик з параметром для редагування
            tooltip: 'Редагувати',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 22),
            onPressed: () => _deleteItem(itemDoc.id),
            tooltip: 'Видалити',
          ),
        ],
      ),
    );
  }
}

// Віджет для "порожнього стану"
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.cartPlus, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'Список поки порожній',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Натисніть "+", щоб додати перший товар',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
