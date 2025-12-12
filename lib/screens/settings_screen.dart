
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart'; 
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shop_helper_app/providers/theme_provider.dart';
import '../core/widgets/main_layout.dart';
import '../core/app_colors.dart';
import 'profile_screen.dart';
import 'auth_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _sortValue = 'За датою';
  final user = FirebaseAuth.instance.currentUser;

  // Видаляємо всю стару логіку, пов'язану з темою
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Вихід з акаунту'),
          content: const Text('Ви впевнені, що хочете вийти зі свого профілю?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Залишитись'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.dangerRed),
              onPressed: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Вийти'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 3,
      title: 'Налаштування',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(context),
          const SizedBox(height: 16),
          _buildInterfaceCard(),
          const SizedBox(height: 16),
          _buildAboutCard(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.signOutAlt),
            label: const Text('Вийти з акаунту'),
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardWhite,
              foregroundColor: AppColors.dangerRed,
              elevation: 1,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildProfileCard(BuildContext context) {
     return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Профіль', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: (user?.photoURL != null) 
                  ? NetworkImage(user!.photoURL!) 
                  : const AssetImage('assets/avatar.png') as ImageProvider,
                backgroundColor: AppColors.backgroundGrey,
              ),
              title: Text(user?.displayName ?? 'Користувач', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(user?.email ?? 'немає email', style: const TextStyle(color: AppColors.textLight)),
              trailing: const Icon(FontAwesomeIcons.chevronRight, size: 16, color: AppColors.textLight),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== ПОВНА І ПРАВИЛЬНА ВЕРСІЯ МЕТОДУ =====
  Widget _buildInterfaceCard() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Інтерфейс', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Темна тема'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                  activeColor: AppColors.darkGreen,
                ),
                ListTile( // <-- ВИПРАВЛЕННЯ №2: ПОВЕРНУЛИ DropdownButton
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Сортування списків'),
                  trailing: DropdownButton<String>(
                    value: _sortValue,
                    underline: const SizedBox(),
                    items: <String>['За датою', 'За назвою']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>( value: value, child: Text(value) );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() { _sortValue = newValue!; });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Про застосунок', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Версія'),
              trailing: Text('1.0.1 (Lab 5)', style: TextStyle(color: AppColors.textLight)),
            ),
            const Divider(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  throw StateError("Це звичайна помилка, оброблена через try-catch.");
                } catch (error, stackTrace) {
                  await Sentry.captureException(error, stackTrace: stackTrace);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Звичайну помилку відправлено в Sentry!'),
                      backgroundColor: AppColors.darkGreen,
                    ));
                  }
                }
              },
              child: const Text('Згенерувати звичайну помилку'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                throw Exception("Це тестова ФАТАЛЬНА помилка для Sentry!");
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
              child: const Text('Згенерувати фатальну помилку', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
