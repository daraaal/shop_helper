
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:shop_helper_app/providers/shopping_lists_provider.dart';
// import '../core/app_colors.dart';
// import '../core/widgets/main_layout.dart';
// import '../models/category.dart';
// import '../models/shopping_list_model.dart'; 
// import 'items_screen.dart';

// class ListScreen extends StatefulWidget {
//   const ListScreen({super.key});

//   @override
//   State<ListScreen> createState() => _ListScreenState();
// }

// class _ListScreenState extends State<ListScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String _searchQuery = '';

//   final List<Color> _cardColors = [
//     AppColors.accentBlue,
//     AppColors.accentOrange,
//     AppColors.accentPurple,
//     Colors.teal.shade400,
//     Colors.indigo.shade400,
//     Colors.brown.shade400,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     Future.microtask(() =>
//         Provider.of<ShoppingListsProvider>(context, listen: false).fetchLists()
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
  
//   IconData _getIconData(String? iconName) {
//     if (iconName == null) return availableCategories.last.iconData;
//     return availableCategories.firstWhere((cat) => cat.iconName == iconName, orElse: () => availableCategories.last).iconData;
//   }
  
//   void _showListDialog({ShoppingListModel? list}) {
//     final bool isEditing = list != null;
    
//     final nameController = TextEditingController(text: isEditing ? list!.name : '');
    
//     Category selectedCategory;
//     if (isEditing) {
//       selectedCategory = availableCategories.firstWhere(
//         (cat) => cat.iconName == list!.icon,
//         orElse: () => availableCategories.first,
//       );
//     } else {
//       selectedCategory = availableCategories.first;
//     }
      
//     final formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               title: Text(isEditing ? 'Редагувати список' : 'Створити новий список'),
//               content: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextFormField(
//                       controller: nameController,
//                       autofocus: true,
//                       decoration: const InputDecoration(labelText: 'Назва списку'),
//                       validator: (value) => (value == null || value.trim().isEmpty) ? 'Назва не може бути порожньою' : null,
//                     ),
//                     const SizedBox(height: 24),
//                     DropdownButtonFormField<Category>(
//                       value: selectedCategory,
//                       decoration: const InputDecoration(labelText: 'Категорія'),
//                       items: availableCategories.map((Category category) {
//                         return DropdownMenuItem<Category>(
//                           value: category,
//                           child: Row(children: [FaIcon(category.iconData, size: 18), const SizedBox(width: 12), Text(category.name)]),
//                         );
//                       }).toList(),
//                       onChanged: (Category? newValue) {
//                         setDialogState(() {
//                           selectedCategory = newValue!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Скасувати')),
//                 FilledButton(
//                   onPressed: () {
//                     if (formKey.currentState!.validate()) {
//                       final listsProvider = Provider.of<ShoppingListsProvider>(context, listen: false);
//                       final data = {
//                         'name': nameController.text.trim(),
//                         'icon': selectedCategory.iconName,
//                       };
//                       if (isEditing) {
//                         listsProvider.updateShoppingList(list!.id, data);
//                       } else {
//                         final randomColor = _cardColors[Random().nextInt(_cardColors.length)].value;
//                         listsProvider.addShoppingList(data, randomColor);
//                       }
//                       Navigator.of(ctx).pop();
//                     }
//                   },
//                   child: Text(isEditing ? 'Зберегти' : 'Створити'),
//                 )
//               ],
//             );
//           }
//         );
//       },
//     );
//   }
  
//   void _deleteList(BuildContext context, String listId) {
//     Provider.of<ShoppingListsProvider>(context, listen: false).deleteShoppingList(listId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MainLayout(
//       selectedIndex: 0,
//       title: 'Мої списки',
//       showSearch: true,
//       onSearchChanged: (query) => setState(() => _searchQuery = query),
//       onAddPressed: () => _showListDialog(),
//       body: RefreshIndicator(
//         onRefresh: () => Provider.of<ShoppingListsProvider>(context, listen: false).fetchLists(),
//         child: Consumer<ShoppingListsProvider>(
//           builder: (context, listsProvider, child) {
            
//             if (listsProvider.isLoading && listsProvider.shoppingLists.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (listsProvider.errorMessage != null) {
//               return Center(child: Text(listsProvider.errorMessage!));
//             }
            
//             if (listsProvider.shoppingLists.isEmpty) {
//                return const Center(
//                 child: Text('У вас ще немає списків.\nСтворіть перший!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight, fontSize: 16)),
//               );
//             }

//             final allLists = listsProvider.shoppingLists;
            
//             final filteredLists = allLists.where((list) {
//               return list.name.toLowerCase().contains(_searchQuery.toLowerCase());
//             }).toList();

//             final activeLists = filteredLists.where((list) {
//               return list.itemCount == 0 || list.boughtCount != list.itemCount;
//             }).toList();

//             final completedLists = filteredLists.where((list) {
//               return list.itemCount > 0 && list.boughtCount == list.itemCount;
//             }).toList();

//             return Column(
//               children: [
//                 Container(
//                   color: Theme.of(context).cardTheme.color ?? AppColors.cardWhite,
//                   child: TabBar(
//                     controller: _tabController,
//                     labelColor: AppColors.darkGreen, 
//                     indicatorColor: AppColors.darkGreen,
//                     tabs: const [Tab(text: 'Активні'), Tab(text: 'Завершені')],
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildGridView(context, activeLists),
//                       _buildGridView(context, completedLists),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
  
//   Widget _buildGridView(BuildContext context, List<ShoppingListModel> lists) {
//     if (lists.isEmpty && _searchQuery.isNotEmpty) {
//       return const Center(
//         child: Text('Нічого не знайдено', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
//       );
//     }
//     return GridView.builder(
//       padding: const EdgeInsets.all(16.0),
//       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 280,
//         childAspectRatio: 1,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: lists.length,
//       itemBuilder: (context, index) => _buildGridListCard(context, lists[index]),
//     );
//   }

//   Widget _buildGridListCard(BuildContext context, ShoppingListModel list) {
    
//     final int itemCount = list.itemCount;
//     final int boughtCount = list.boughtCount;
//     final progress = itemCount > 0 ? (boughtCount / itemCount) : 0.0;
//     final color = Color(list.color);
    
//     final String iconName = list.icon;
//     final IconData iconData = _getIconData(iconName);
//     final String categoryName = availableCategories.firstWhere((cat) => cat.iconName == iconName, orElse: () => availableCategories.last).name;

//     return Card(
//       color: color,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       clipBehavior: Clip.antiAlias,
//       elevation: 4,
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: Center(
//               child: FaIcon(iconData, size: 100, color: Colors.white.withOpacity(0.1)),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => ItemsScreen(
//                 listId: list.id, // ID тепер береться з моделі
//                 listName: list.name,
//                 listIconName: iconName,
//               ))).then((_) {
//                 Provider.of<ShoppingListsProvider>(context, listen: false).fetchLists();
//               });
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         FaIcon(iconData, color: Colors.white, size: 12),
//                         const SizedBox(width: 6),
//                         Text(categoryName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(list.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1))])),
//                   const SizedBox(height: 8),
//                   Text('$boughtCount з $itemCount куплено', style: TextStyle(color: Colors.white.withOpacity(0.9))),
//                   const SizedBox(height: 8),
//                   if (itemCount > 0)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: LinearProgressIndicator(
//                         value: progress,
//                         backgroundColor: Colors.white.withOpacity(0.3),
//                         color: Colors.white,
//                         minHeight: 6,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: 4,
//             right: 4,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _ActionButton(icon: Icons.edit, onTap: () => _showListDialog(list: list)), // Передаємо модель
//                 _ActionButton(icon: Icons.delete, onTap: () => _deleteList(context, list.id)), // Передаємо ID
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _ActionButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           padding: const EdgeInsets.all(6.0),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.15),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
//         ),
//       ),
//     );
//   }
// }



import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shop_helper_app/providers/shopping_lists_provider.dart';
import 'package:shop_helper_app/providers/sort_provider.dart';
import '../core/app_colors.dart';
import '../core/widgets/main_layout.dart';
import '../models/category.dart';
import '../models/shopping_list_model.dart'; 
import 'items_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  late Future<void> _fetchListsFuture;

  final List<Color> _cardColors = [
    AppColors.accentBlue,
    AppColors.accentOrange,
    AppColors.accentPurple,
    Colors.teal.shade400,
    Colors.indigo.shade400,
    Colors.brown.shade400,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Ініціалізуємо майбутнє завантаження даних тут
    _fetchListsFuture = Provider.of<ShoppingListsProvider>(context, listen: false).fetchLists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  IconData _getIconData(String? iconName) {
    if (iconName == null) return availableCategories.last.iconData;
    return availableCategories.firstWhere((cat) => cat.iconName == iconName, orElse: () => availableCategories.last).iconData;
  }
  
  void _showListDialog({ShoppingListModel? list}) {
    final bool isEditing = list != null;
    final nameController = TextEditingController(text: isEditing ? list.name : '');
    
    Category selectedCategory = isEditing
        ? availableCategories.firstWhere((cat) => cat.iconName == list.icon, orElse: () => availableCategories.first)
        : availableCategories.first;
      
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isEditing ? 'Редагувати список' : 'Створити новий список'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Назва списку'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Назва не може бути порожньою' : null,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<Category>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Категорія'),
                    items: availableCategories.map((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Row(children: [FaIcon(category.iconData, size: 18), const SizedBox(width: 12), Text(category.name)]),
                      );
                    }).toList(),
                    onChanged: (Category? newValue) {
                      if (newValue != null) {
                        setDialogState(() => selectedCategory = newValue);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Скасувати')),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    final listsProvider = Provider.of<ShoppingListsProvider>(context, listen: false);
                    final data = {
                      'name': nameController.text.trim(),
                      'icon': selectedCategory.iconName,
                    };
                    if (isEditing) {
                      listsProvider.updateShoppingList(list.id, data);
                    } else {
                      final randomColor = _cardColors[Random().nextInt(_cardColors.length)].value;
                      listsProvider.addShoppingList(data, randomColor);
                    }
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(isEditing ? 'Зберегти' : 'Створити'),
              )
            ],
          );
        }
      ),
    );
  }
  
  void _deleteList(BuildContext context, String listId) {
    Provider.of<ShoppingListsProvider>(context, listen: false).deleteShoppingList(listId);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MainLayout(
  //     selectedIndex: 0,
  //     title: 'Мої списки',
  //     showSearch: true,
  //     onSearchChanged: (query) => setState(() => _searchQuery = query),
  //     onAddPressed: () => _showListDialog(),
  //     body: FutureBuilder(
  //       future: _fetchListsFuture,
  //       builder: (ctx, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }
  //         // Якщо при першому завантаженні сталася помилка
  //         if (snapshot.hasError) {
  //            return Center(child: Text('Помилка завантаження даних: ${snapshot.error}'));
  //         }

  //         // Після успішного завантаження показуємо UI
  //         return RefreshIndicator(
  //           onRefresh: () => Provider.of<ShoppingListsProvider>(context, listen: false).fetchLists(),
  //           child: Consumer<ShoppingListsProvider>(
  //             builder: (context, listsProvider, child) {
  //               if (listsProvider.isLoading && listsProvider.shoppingLists.isEmpty) {
  //                 return const Center(child: CircularProgressIndicator());
  //               }

  //               if (listsProvider.errorMessage != null) {
  //                 return Center(child: Text(listsProvider.errorMessage!));
  //               }
                
  //               if (listsProvider.shoppingLists.isEmpty) {
  //                 return const Center(
  //                   child: Text('У вас ще немає списків.\nСтворіть перший!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.textLight)),
  //                 );
  //               }

  //               final allLists = listsProvider.shoppingLists;
  //               final filteredLists = allLists.where((list) => list.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  //               final activeLists = filteredLists.where((list) => list.itemCount == 0 || list.boughtCount != list.itemCount).toList();
  //               final completedLists = filteredLists.where((list) => list.itemCount > 0 && list.boughtCount == list.itemCount).toList();

  //               return Column(
  //                 children: [
  //                   Container(
  //                     color: Theme.of(context).cardTheme.color ?? AppColors.cardWhite,
  //                     child: TabBar(
  //                       controller: _tabController,
  //                       tabs: const [Tab(text: 'Активні'), Tab(text: 'Завершені')],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: TabBarView(
  //                       controller: _tabController,
  //                       children: [
  //                         _buildGridView(context, activeLists),
  //                         _buildGridView(context, completedLists),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         );
  //       }
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 0,
      title: 'Мої списки',
      showSearch: true,
      onSearchChanged: (query) => setState(() => _searchQuery = query),
      onAddPressed: () => _showListDialog(),
      body: FutureBuilder(
        future: _fetchListsFuture, // Використовуємо FutureBuilder для початкового завантаження
        builder: (ctx, snapshot) {
          // Поки дані завантажуються вперше, показуємо індикатор
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Якщо при першому завантаженні сталася помилка
          if (snapshot.hasError) {
            return Center(child: Text('Помилка завантаження даних: ${snapshot.error}'));
          }

          // Коли дані завантажено, показуємо основний UI з Consumer
          return RefreshIndicator(
            onRefresh: () => Provider.of<ShoppingListsProvider>(context, listen: false).fetchLists(),
            child: Consumer2<ShoppingListsProvider, SortProvider>(
              builder: (context, listsProvider, sortProvider, child) {
                
                if (listsProvider.isLoading && listsProvider.shoppingLists.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (listsProvider.errorMessage != null) {
                  return Center(child: Text(listsProvider.errorMessage!));
                }
                
                if (listsProvider.shoppingLists.isEmpty) {
                  return const Center(
                    child: Text('У вас ще немає списків.\nСтворіть перший!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                  );
                }

                // --- ОСНОВНА ЛОГІКА СОРТУВАННЯ ТА ФІЛЬТРАЦІЇ ---
                final allLists = listsProvider.shoppingLists;

                // 1. Сортуємо копію списку
                final sortedLists = List<ShoppingListModel>.from(allLists);
                if (sortProvider.sortOption == SortOption.byName) {
                  sortedLists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                } 
                // `else` для сортування за датою не потрібен, бо дані з Firebase вже так відсортовані

                // 2. Фільтруємо відсортований список за пошуковим запитом
                final filteredLists = sortedLists.where((list) {
                  return list.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                // 3. Розділяємо на активні та завершені
                final activeLists = filteredLists.where((list) {
                  return list.itemCount == 0 || list.boughtCount != list.itemCount;
                }).toList();

                final completedLists = filteredLists.where((list) {
                  return list.itemCount > 0 && list.boughtCount == list.itemCount;
                }).toList();

                // --- ПОБУДОВА UI ---
                return Column(
                  children: [
                    Container(
                      color: Theme.of(context).cardTheme.color ?? AppColors.cardWhite,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [Tab(text: 'Активні'), Tab(text: 'Завершені')],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGridView(context, activeLists),
                          _buildGridView(context, completedLists),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildGridView(BuildContext context, List<ShoppingListModel> lists) {
    if (lists.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
        child: Text('Нічого не знайдено', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: lists.length,
      itemBuilder: (context, index) => _buildGridListCard(context, lists[index]),
    );
  }

  Widget _buildGridListCard(BuildContext context, ShoppingListModel list) {
    final progress = list.itemCount > 0 ? (list.boughtCount / list.itemCount) : 0.0;
    final color = Color(list.color);
    final iconData = _getIconData(list.icon);
    final categoryName = availableCategories.firstWhere((cat) => cat.iconName == list.icon, orElse: () => availableCategories.last).name;

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: FaIcon(iconData, size: 100, color: Colors.white.withOpacity(0.1)),
            ),
          ),
          InkWell(
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => ItemsScreen(
            //         listId: list.id,
            //         listName: list.name,
            //         listIconName: list.icon,
            //       )
            //     ),
            //   );
            // },
            onTap: () async { // <-- Робимо функцію асинхронною
              // Переходимо на екран і чекаємо, поки він закриється
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemsScreen(
                    listId: list.id,
                    listName: list.name,
                    listIconName: list.icon,
                  )
                ),
              );

              // Коли ми повернулися, оновлюємо дані для цього списку
              if (mounted) {
                Provider.of<ShoppingListsProvider>(context, listen: false).refreshSingleList(list.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(iconData, color: Colors.white, size: 12),
                        const SizedBox(width: 6),
                        Text(categoryName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(list.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1))])),
                  const SizedBox(height: 8),
                  Text('${list.boughtCount} з ${list.itemCount} куплено', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 8),
                  if (list.itemCount > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        color: Colors.white,
                        minHeight: 6,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(icon: Icons.edit, onTap: () => _showListDialog(list: list)),
                _ActionButton(icon: Icons.delete, onTap: () => _deleteList(context, list.id)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        ),
      ),
    );
  }
}