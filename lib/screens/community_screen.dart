
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../core/app_colors.dart';
import '../core/widgets/main_layout.dart';
import '../models/category.dart';

class CommunityScreen extends StatelessWidget {
  // ===== ОСЬ ВИПРАВЛЕННЯ: прибираємо 'const' =====
  CommunityScreen({super.key});
  // ===============================================

  static final List<Map<String, dynamic>> _communityLists = [
    {
      'title': '🥑 Здорове харчування', 'author': 'Олена', 'likes': 125, 'categoryIcon': 'carrot',
      'items': ['Авокадо', 'Кіноа', 'Шпинат', 'Лосось', 'Оливкова олія', 'Броколі', 'Горіхи']
    },
    {
      'title': '🏕 Похід на вихідні', 'author': 'Максим', 'likes': 98, 'categoryIcon': 'campground',
      'items': ['Намет', 'Спальник', 'Сірники', 'Консерви', 'Вода 5л', 'Ліхтарик', 'Аптечка']
    },
    {
      'title': '🎉 До дня народження', 'author': 'Світлана', 'likes': 76, 'categoryIcon': 'birthdayCake',
      'items': ['Торт', 'Свічки', 'Повітряні кульки', 'Одноразовий посуд', 'Соки', 'Серветки']
    },
    {
      'title': '🧼 Генеральне прибирання', 'author': 'Ірина', 'likes': 88, 'categoryIcon': 'soap',
      'items': ['Засіб для миття вікон', 'Поліроль для меблів', 'Сміттєві пакети', 'Губки', 'Рукавички']
    },
    {
      'title': '🎨 Ремонт у кімнаті', 'author': 'Андрій', 'likes': 64, 'categoryIcon': 'paintRoller',
      'items': ['Фарба (біла)', 'Валик', 'Плівка для захисту', 'Малярний скотч', 'Шпаклівка']
    },
    {
      'title': '🌍 Подорож в іншу країну', 'author': 'Катя', 'likes': 150, 'categoryIcon': 'campground',
      'items': ['Паспорт', 'Квитки', 'Страховка', 'Зарядний пристрій', 'Адаптер для розеток', 'Сонцезахисний крем']
    },
  ];

  final List<Color> _cardColors = [
    AppColors.accentBlue,
    AppColors.accentOrange,
    AppColors.accentPurple,
    Colors.teal.shade400,
    Colors.indigo.shade400,
    Colors.brown.shade400,
  ];

  void _copyList(BuildContext context, Map<String, dynamic> listData) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final randomColor = _cardColors[Random().nextInt(_cardColors.length)].value;

      final newListRef = await FirebaseFirestore.instance.collection('shopping_lists').add({
        'name': listData['title'],
        'userId': userId,
        'createdAt': Timestamp.now(),
        'itemCount': 0,
        'boughtCount': 0,
        'icon': listData['categoryIcon'],
        'color': randomColor,
      });

      final itemsToAdd = (listData['items'] as List<String>).map((itemName) => {
        'name': itemName, 'qty': '', 'bought': false, 'createdAt': Timestamp.now(), 'category': '',
      }).toList();

      final batch = FirebaseFirestore.instance.batch();
      for (var item in itemsToAdd) {
        final itemRef = newListRef.collection('items').doc();
        batch.set(itemRef, item);
      }
      await batch.commit();

      await newListRef.update({'itemCount': itemsToAdd.length});
      
      await FirebaseAnalytics.instance.logEvent(
        name: 'copy_community_list',
        parameters: {'list_title': listData['title'], 'list_author': listData['author']},
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Список успішно скопійовано!'),
          backgroundColor: AppColors.darkGreen,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Не вдалося скопіювати список.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 2,
      title: 'Спільнота',
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _communityLists.length,
        itemBuilder: (context, index) {
          return _buildCommunityCard(context, _communityLists[index]);
        },
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, Map<String, dynamic> listData) {
    final iconData = availableCategories
        .firstWhere((cat) => cat.iconName == listData['categoryIcon'], orElse: () => availableCategories.last)
        .iconData;
    
    final itemCount = (listData['items'] as List).length;

    return Card(
      //color: AppColors.cardWhite,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: Theme.of(context).brightness == Brightness.dark 
          ? const BorderSide(color: Color(0xFF333333), width: 1)
          : BorderSide.none,
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listData['title'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('Автор: ${listData['author']}', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: FaIcon(
                iconData,
                size: 60,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.list, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text('$itemCount товарів', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.solidHeart, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text('${listData['likes']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _copyList(context, listData),
            icon: const Icon(FontAwesomeIcons.copy, size: 14),
            label: const Text('Скопіювати'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.textDark,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}