
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_colors.dart';
import 'shop_helper_logo.dart';
import '../../screens/list_screen.dart';
import '../../screens/statistics_screen.dart';
import '../../screens/community_screen.dart';
import '../../screens/settings_screen.dart';

class MainLayout extends StatefulWidget {
  final int selectedIndex;
  final Widget body;
  final String title;
  final bool showSearch;
  final Function(String)? onSearchChanged;
  final VoidCallback? onAddPressed;

  const MainLayout({
    super.key,
    required this.selectedIndex,
    required this.body,
    required this.title,
    this.showSearch = false,
    this.onSearchChanged,
    this.onAddPressed,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.onSearchChanged?.call(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Прибираємо всю логіку з isDarkMode, віджети тепер самі беруть кольори з теми
    return Scaffold(
      appBar: AppBar(
        // backgroundColor та foregroundColor тепер беруться з AppBarTheme
        elevation: 1,
        automaticallyImplyLeading: false,
        leadingWidth: 160,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              ShopHelperLogo(),
              SizedBox(width: 8),
              Text(
                'ShopHelper',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        title: _buildAppBarTitle(),
        centerTitle: true,
        actions: _buildAppBarActions(),
      ),
      body: widget.body,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddPressed,
        backgroundColor: AppColors.darkGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        // color тепер береться з BottomAppBarTheme
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, context, icon: FontAwesomeIcons.listUl, label: 'Списки'),
            _buildNavItem(1, context, icon: FontAwesomeIcons.chartBar, label: 'Статистика'),
            const SizedBox(width: 48),
            _buildNavItem(2, context, icon: FontAwesomeIcons.users, label: 'Спільнота'),
            _buildNavItem(3, context, icon: FontAwesomeIcons.cog, label: 'Профіль'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Пошук...',
          border: InputBorder.none,
        ),
        // Колір тексту буде братися з теми автоматично
      );
    } else {
      return Text(widget.title); // Стиль буде братися з теми автоматично
    }
  }


  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
      ];
    } else if (widget.showSearch) {
      return [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textDark),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ];
    }
    return [];
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == widget.selectedIndex) return;
    Widget page;
    switch (index) {
      case 0: page = const ListScreen(); break;
      case 1: page = const StatisticsScreen(); break;
      case 2: page = CommunityScreen(); break;
      case 3: page = const SettingsScreen(); break;
      default: page = const ListScreen();
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: Duration.zero),
    );
  }
  
  /*
  // Widget _buildNavItem(int index, BuildContext context, {required IconData icon, required String label}) {
  //   final bool isActive = widget.selectedIndex == index;
  //   // Для іконок навігації колір тексту має бути темним, бо фон білий
  //   return InkWell(
  //     onTap: () => _onItemTapped(index, context),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           FaIcon(icon, color: isActive ? AppColors.darkGreen : AppColors.textLight, size: 20),
  //           const SizedBox(height: 4),
  //           Text(label, style: TextStyle(color: isActive ? AppColors.darkGreen : AppColors.textLight, fontSize: 11)),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  */
  
  Widget _buildNavItem(int index, BuildContext context, {required IconData icon, required String label}) {
    final bool isActive = widget.selectedIndex == index;
    // Кольори для іконок навігації тепер адаптивні
    final activeColor = AppColors.darkGreen;
    final inactiveColor = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textLight;

    return InkWell(
      onTap: () => _onItemTapped(index, context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: isActive ? activeColor : inactiveColor, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? activeColor : inactiveColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}