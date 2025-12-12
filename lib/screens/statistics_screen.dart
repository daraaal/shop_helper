
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../core/widgets/main_layout.dart';

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
    final userId = FirebaseAuth.instance.currentUser!.uid;
    int totalItemsBought = 0;
    int listsCompleted = 0;
    Map<String, int> popularItemsCounter = {};
    Map<String, double> categoryItemCount = {}; // <-- НОВА МАПА ДЛЯ ДІАГРАМИ

    final listsSnapshot = await FirebaseFirestore.instance
        .collection('shopping_lists')
        .where('userId', isEqualTo: userId)
        .get();

    for (var listDoc in listsSnapshot.docs) {
      final listData = listDoc.data();
      totalItemsBought += (listData['boughtCount'] ?? 0) as int;
      final itemCount = (listData['itemCount'] ?? 0) as int;
      if (itemCount > 0 && itemCount == (listData['boughtCount'] ?? 0)) {
        listsCompleted++;
      }
      
      final itemsSnapshot = await listDoc.reference.collection('items').get();
      for (var itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();
        final itemName = itemData['name'] as String;
        popularItemsCounter.update(itemName, (value) => value + 1, ifAbsent: () => 1);
        
        // <-- НОВА ЛОГІКА: Рахуємо товари за категоріями -->
        String category = itemData['category']?.trim() ?? '';
        if (category.isEmpty) {
          category = 'Без категорії'; // Групуємо всі товари без категорії
        }
        categoryItemCount.update(category, (value) => value + 1, ifAbsent: () => 1.0);
      }
    }

    final sortedPopularItems = popularItemsCounter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return {
      'totalItemsBought': totalItemsBought,
      'listsCompleted': listsCompleted,
      'popularItems': sortedPopularItems,
      'categoryData': categoryItemCount, // <-- Передаємо дані для діаграми
    };
  }
  
  // Дані для діаграми залишаються статичними, оскільки в моделі даних немає категорій.
  // Для реалізації динамічної діаграми потрібно додати поле "category" до кожного товару.
  final Map<String, double> dataMap = const {
    "Продукти": 70,
    "Побут. хімія": 50,
    "Для дачі": 30,
  };
  
  final List<Color> colorList = const [
    AppColors.accentOrange,
    AppColors.accentBlue,
    AppColors.accentPurple,
  ];

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
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Немає даних для відображення'));
          }

          final stats = snapshot.data!;
          final int totalItemsBought = stats['totalItemsBought'];
          final int listsCompleted = stats['listsCompleted'];
          final List<MapEntry<String, int>> popularItems = stats['popularItems'];

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
                _buildCategoryChartCard(),
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

  Widget _buildCategoryChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Витрати за категоріями (приклад)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            PieChart(
              dataMap: dataMap,
              animationDuration: const Duration(milliseconds: 800),
              chartLegendSpacing: 32,
              chartRadius: 150,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: "ВИТРАТИ",
              legendOptions: const LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
                decimalPlaces: 0,
              ),
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
            const Text('Найпопулярніші товари', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Ви ще не додали жодного товару.', style: TextStyle(color: AppColors.textLight)),
              ))
            else
              ...items.take(3).map((entry) {
                final index = items.indexOf(entry);
                return Column(
                  children: [
                    _buildPopularItem('${index + 1}. ${entry.key}', '${entry.value} разів'),
                    if (index < 2 && index < items.length - 1) const Divider(),
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