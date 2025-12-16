
/*
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../core/widgets/main_layout.dart';
import '../models/category.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Future<Map<String, dynamic>>? _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _fetchStatistics();
  }

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return {};

    int totalItemsBought = 0;
    int listsCompleted = 0;
    Map<String, int> popularItemsCounter = {};
    Map<String, double> categoryItemCount = {}; // Кількість товарів у кожній категорії

    // 1. Отримуємо всі списки користувача
    final listsSnapshot = await FirebaseFirestore.instance
        .collection('shopping_lists')
        .where('userId', isEqualTo: userId)
        .get();

    // 2. Ітеруємо по списках, щоб зібрати статистику
    for (var listDoc in listsSnapshot.docs) {
      final listData = listDoc.data();
      final int itemCount = (listData['itemCount'] ?? 0) as int;
      final int boughtCount = (listData['boughtCount'] ?? 0) as int;

      totalItemsBought += boughtCount;
      if (itemCount > 0 && itemCount == boughtCount) {
        listsCompleted++;
      }
      
      // --- НОВА ЛОГІКА ДЛЯ ДІАГРАМИ ---
      // Знаходимо назву категорії за іконкою самого списку
      final String iconName = listData['icon'] ?? 'asterisk';
      final String categoryName = availableCategories
          .firstWhere((cat) => cat.iconName == iconName, orElse: () => availableCategories.last)
          .name;
      
      // Додаємо кількість товарів з цього списку до загального лічильника категорії
      categoryItemCount.update(categoryName, (value) => value + itemCount, ifAbsent: () => itemCount.toDouble());
      // ------------------------------------

      // Логіка для популярних товарів залишається
      final itemsSnapshot = await listDoc.reference.collection('items').get();
      for (var itemDoc in itemsSnapshot.docs) {
        final itemName = itemDoc.data()['name'] as String;
        popularItemsCounter.update(itemName, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final sortedPopularItems = popularItemsCounter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return {
      'totalItemsBought': totalItemsBought,
      'listsCompleted': listsCompleted,
      'popularItems': sortedPopularItems,
      'categoryData': categoryItemCount,
    };
  
  }
  
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 1,
      title: 'Статистика', 
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Помилка завантаження статистики: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('Немає даних для відображення'));
          }

          final stats = snapshot.data!;
          final int totalItemsBought = stats['totalItemsBought'];
          final int listsCompleted = stats['listsCompleted'];
          final List<MapEntry<String, int>> popularItems = stats['popularItems'];
          final Map<String, double> categoryData = stats['categoryData'];

          return RefreshIndicator(
            onRefresh: () {
              setState(() {
                _statisticsFuture = _fetchStatistics();
              });
              return _statisticsFuture!;
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatsGrid(totalItemsBought, listsCompleted),
                const SizedBox(height: 24),
                _buildCategoryChartCard(categoryData),
                const SizedBox(height: 16),
                _buildPopularItemsCard(popularItems),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(int itemsBought, int listsCompleted) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(icon: FontAwesomeIcons.basketShopping, value: itemsBought.toString(), label: 'Товарів куплено', color: AppColors.accentOrange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(icon: FontAwesomeIcons.checkDouble, value: listsCompleted.toString(), label: 'Списків завершено', color: AppColors.darkGreen)),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: color, radius: 24, child: FaIcon(icon, color: Colors.white, size: 20)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChartCard(Map<String, double> categoryData) {
  if (categoryData.isEmpty) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Кількість товарів за категоріями', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('Додайте категорії до ваших товарів,\nщоб побачити тут статистику.', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final colorList = categoryData.keys.map((key) {
    return Color(key.hashCode | 0xFF000000).withOpacity(1.0);
  }).toList();

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Кількість товарів за категоріями', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          PieChart(
            dataMap: categoryData,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 42, // Збільшуємо відстань між легендою і діаграмою
            chartRadius: MediaQuery.of(context).size.width / 3.2 > 150 ? 150 : MediaQuery.of(context).size.width / 3.2,
            colorList: colorList,
            initialAngleInDegree: -90, // Починаємо зверху
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "КАТЕГОРІЇ",
            legendOptions: const LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false, // Прибираємо фон, щоб було чистіше
              showChartValues: true,
              showChartValuesInPercentage: true, // Показуємо відсотки, це більш інформативно
              showChartValuesOutside: true, // Виносимо значення за межі діаграми
              decimalPlaces: 0,
            ),
            gradientList: colorList.map((color) => [color.withOpacity(0.8), color]).toList(),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPopularItemsCard(List<MapEntry<String, int>> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Найпопулярніші товари', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('Ви ще не додали жодного товару.', style: TextStyle(color: AppColors.textLight)),
              ))
            else
              ...items.take(5).map((entry) { // Показуємо до 5 популярних товарів
                final index = items.indexOf(entry);
                return Column(
                  children: [
                    _buildPopularItem('${index + 1}. ${entry.key}', '${entry.value} разів'),
                    if (index < 4 && index < items.length - 1) const Divider(height: 1),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItem(String name, String count) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(name),
      trailing: Text(count, style: const TextStyle(color: AppColors.textLight)),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../core/widgets/main_layout.dart';
import '../models/category.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return {};

    int totalItemsBought = 0;
    int listsCompleted = 0;
    Map<String, int> popularItemsCounter = {};
    Map<String, double> categoryItemCount = {};

    final listsSnapshot = await FirebaseFirestore.instance
        .collection('shopping_lists')
        .where('userId', isEqualTo: userId)
        .get();

    for (var listDoc in listsSnapshot.docs) {
      final listData = listDoc.data();
      final int itemCount = (listData['itemCount'] ?? 0) as int;
      final int boughtCount = (listData['boughtCount'] ?? 0) as int;

      totalItemsBought += boughtCount;
      if (itemCount > 0 && itemCount == boughtCount) {
        listsCompleted++;
      }
      
      final String iconName = listData['icon'] ?? 'asterisk';
      final String categoryName = availableCategories
          .firstWhere((cat) => cat.iconName == iconName, orElse: () => availableCategories.last)
          .name;
      
      categoryItemCount.update(categoryName, (value) => value + itemCount, ifAbsent: () => itemCount.toDouble());

      final itemsSnapshot = await listDoc.reference.collection('items').get();
      for (var itemDoc in itemsSnapshot.docs) {
        final itemName = itemDoc.data()['name'] as String;
        popularItemsCounter.update(itemName, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final sortedPopularItems = popularItemsCounter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return {
      'totalItemsBought': totalItemsBought,
      'listsCompleted': listsCompleted,
      'popularItems': sortedPopularItems,
      'categoryData': categoryItemCount,
    };
  }
  
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 1,
      title: 'Статистика', 
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStatistics(), // <-- Дані завантажуються тут при кожній побудові
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Помилка завантаження статистики: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('Немає даних для відображення'));
          }

          final stats = snapshot.data!;
          final int totalItemsBought = stats['totalItemsBought'];
          final int listsCompleted = stats['listsCompleted'];
          final List<MapEntry<String, int>> popularItems = stats['popularItems'];
          final Map<String, double> categoryData = stats['categoryData'];

          // Обертаємо в RefreshIndicator, але тепер він не обов'язковий,
          // оскільки дані оновлюються при кожному відкритті вкладки.
          // Проте, залишимо його для зручності.
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Просто перебудовуємо віджет, що викличе _fetchStatistics() знову
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatsGrid(totalItemsBought, listsCompleted),
                const SizedBox(height: 24),
                _buildCategoryChartCard(categoryData),
                const SizedBox(height: 16),
                _buildPopularItemsCard(popularItems),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(int itemsBought, int listsCompleted) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(icon: FontAwesomeIcons.basketShopping, value: itemsBought.toString(), label: 'Товарів куплено', color: AppColors.accentOrange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(icon: FontAwesomeIcons.checkDouble, value: listsCompleted.toString(), label: 'Списків завершено', color: AppColors.darkGreen)),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: color, radius: 24, child: FaIcon(icon, color: Colors.white, size: 20)),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChartCard(Map<String, double> categoryData) {
    // Прибираємо категорії з 0 товарів, щоб не засмічувати діаграму
    final filteredCategoryData = Map<String, double>.from(categoryData)
      ..removeWhere((key, value) => value == 0);

    if (filteredCategoryData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Кількість товарів за категоріями', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Додайте товари до списків,\nщоб побачити тут статистику.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final colorList = filteredCategoryData.keys.map((key) {
      return Color(key.hashCode | 0xFF000000).withOpacity(1.0);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Кількість товарів за категоріями', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            PieChart(
              dataMap: filteredCategoryData,
              animationDuration: const Duration(milliseconds: 800),
              chartLegendSpacing: 42,
              chartRadius: MediaQuery.of(context).size.width / 3.2 > 150 ? 150 : MediaQuery.of(context).size.width / 3.2,
              colorList: colorList,
              initialAngleInDegree: -90,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: "КАТЕГОРІЇ",
              legendOptions: const LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: false,
                showChartValues: true,
                showChartValuesInPercentage: true,
                showChartValuesOutside: true,
                decimalPlaces: 0,
              ),
              gradientList: colorList.map((color) => [color.withOpacity(0.8), color]).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItemsCard(List<MapEntry<String, int>> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Найпопулярніші товари', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('Ви ще не додали жодного товару.', style: TextStyle(color: AppColors.textLight)),
              ))
            else
              ...items.take(5).map((entry) {
                final index = items.indexOf(entry);
                return Column(
                  children: [
                    _buildPopularItem('${index + 1}. ${entry.key}', '${entry.value} разів'),
                    if (index < 4 && index < items.length - 1) const Divider(height: 1),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItem(String name, String count) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(name),
      trailing: Text(count),
    );
  }
}

