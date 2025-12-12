
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../core/app_colors.dart';
// import '../core/widgets/custom_button.dart';
// import '../core/widgets/custom_text_field.dart';

// class AddItemScreen extends StatelessWidget {
//   const AddItemScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundGrey,
//       appBar: AppBar(
//         title: const Text('Додати товар'),
//         backgroundColor: AppColors.primaryGreen,
//         foregroundColor: AppColors.textDark,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: const Padding(
//         padding: EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             CustomTextField(labelText: 'Назва', hintText: 'Молоко'),
//             SizedBox(height: 20),
//             CustomTextField(labelText: 'Кількість', hintText: '1 упаковка'),
//             SizedBox(height: 20),
//             CustomTextField(labelText: 'Примітка', hintText: 'Опціонально'),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildFooter(context),
//     );
//   }

//   Widget _buildFooter(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       color: AppColors.cardWhite,
//       child: Row(
//         children: [
//           Expanded(
//             child: CustomButton(
//               text: 'Скасувати',
//               icon: FontAwesomeIcons.xmark,
//               type: ButtonType.ghost,
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: CustomButton(
//               text: 'Додати',
//               icon: FontAwesomeIcons.check,
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';

class AddItemScreen extends StatefulWidget {
  final String listId;
  const AddItemScreen({super.key, required this.listId});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController(); // Примітка не використовується, але залишив
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(widget.listId)
          .collection('items')
          .add({
        'name': _nameController.text.trim(),
        'qty': _qtyController.text.trim(),
        'note': _noteController.text.trim(),
        'bought': false,
        'createdAt': Timestamp.now(),
      }).then((_) {
        FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(widget.listId)
          .update({'itemCount': FieldValue.increment(1)});
        
        Navigator.of(context).pop();
      }).catchError((error) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Не вдалося додати товар. Спробуйте ще раз.'))
         );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Додати товар'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Назва',
                hintText: 'Молоко',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Назва товару не може бути порожньою';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _qtyController,
                labelText: 'Кількість',
                hintText: '1 упаковка',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _noteController,
                labelText: 'Примітка',
                hintText: 'Опціонально',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.cardWhite,
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Скасувати',
                  icon: FontAwesomeIcons.xmark,
                  type: ButtonType.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Додати',
                  icon: FontAwesomeIcons.check,
                  onPressed: _saveItem,
                ),
              ),
            ],
          ),
    );
  }
}