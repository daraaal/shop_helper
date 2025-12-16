
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart'; 
// import 'package:sentry_flutter/sentry_flutter.dart';
// import 'package:shop_helper_app/providers/theme_provider.dart';
// import '../core/widgets/main_layout.dart';
// import '../core/app_colors.dart';
// import 'profile_screen.dart';
// import 'auth_screen.dart'; 

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   String _sortValue = 'За датою';
//   final user = FirebaseAuth.instance.currentUser;

//   // Видаляємо всю стару логіку, пов'язану з темою
  
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Вихід з акаунту'),
//           content: const Text('Ви впевнені, що хочете вийти зі свого профілю?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Залишитись'),
//             ),
//             FilledButton(
//               style: FilledButton.styleFrom(backgroundColor: AppColors.dangerRed),
//               onPressed: () async {
//                 await GoogleSignIn().signOut();
//                 await FirebaseAuth.instance.signOut();
//                 if (mounted) {
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(builder: (context) => const AuthScreen()),
//                     (Route<dynamic> route) => false,
//                   );
//                 }
//               },
//               child: const Text('Вийти'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MainLayout(
//       selectedIndex: 3,
//       title: 'Налаштування',
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildProfileCard(context),
//           const SizedBox(height: 16),
//           _buildInterfaceCard(),
//           const SizedBox(height: 16),
//           _buildAboutCard(),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             icon: const Icon(FontAwesomeIcons.signOutAlt),
//             label: const Text('Вийти з акаунту'),
//             onPressed: () => _showLogoutDialog(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.cardWhite,
//               foregroundColor: AppColors.dangerRed,
//               elevation: 1,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//           )
//         ],
//       ),
//     );
//   }
  
//   Widget _buildProfileCard(BuildContext context) {
//      return Card(
//       elevation: 1,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Профіль', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundImage: (user?.photoURL != null) 
//                   ? NetworkImage(user!.photoURL!) 
//                   : const AssetImage('assets/avatar.png') as ImageProvider,
//                 backgroundColor: AppColors.backgroundGrey,
//               ),
//               title: Text(user?.displayName ?? 'Користувач', style: const TextStyle(fontWeight: FontWeight.w600)),
//               subtitle: Text(user?.email ?? 'немає email', style: const TextStyle(color: AppColors.textLight)),
//               trailing: const Icon(FontAwesomeIcons.chevronRight, size: 16, color: AppColors.textLight),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ProfileScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===== ПОВНА І ПРАВИЛЬНА ВЕРСІЯ МЕТОДУ =====
//   Widget _buildInterfaceCard() {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Card(
//           elevation: 1,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Інтерфейс', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 SwitchListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: const Text('Темна тема'),
//                   value: themeProvider.isDarkMode,
//                   onChanged: (value) {
//                     Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
//                   },
//                   activeColor: AppColors.darkGreen,
//                 ),
//                 ListTile( // <-- ВИПРАВЛЕННЯ №2: ПОВЕРНУЛИ DropdownButton
//                   contentPadding: EdgeInsets.zero,
//                   title: const Text('Сортування списків'),
//                   trailing: DropdownButton<String>(
//                     value: _sortValue,
//                     underline: const SizedBox(),
//                     items: <String>['За датою', 'За назвою']
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>( value: value, child: Text(value) );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() { _sortValue = newValue!; });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAboutCard() {
//     return Card(
//       elevation: 1,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text('Про застосунок', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             const ListTile(
//               contentPadding: EdgeInsets.zero,
//               title: Text('Версія'),
//               trailing: Text('1.0.1 (Lab 5)', style: TextStyle(color: AppColors.textLight)),
//             ),
//             const Divider(height: 24),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   throw StateError("Це звичайна помилка, оброблена через try-catch.");
//                 } catch (error, stackTrace) {
//                   await Sentry.captureException(error, stackTrace: stackTrace);
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                       content: Text('Звичайну помилку відправлено в Sentry!'),
//                       backgroundColor: AppColors.darkGreen,
//                     ));
//                   }
//                 }
//               },
//               child: const Text('Згенерувати звичайну помилку'),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () {
//                 throw Exception("Це тестова ФАТАЛЬНА помилка для Sentry!");
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
//               child: const Text('Згенерувати фатальну помилку', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart'; 
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shop_helper_app/providers/theme_provider.dart';
import 'package:shop_helper_app/providers/sort_provider.dart';
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
  // ignore: unused_field
  String _sortValue = 'За датою';
  final user = FirebaseAuth.instance.currentUser;

  void _showLogoutDialog(BuildContext context) {
    bool isLoggingOut = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Вихід з акаунту'),
              content: isLoggingOut
                  ? const Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 24),
                        Text('Виконується вихід...'),
                      ],
                    )
                  : const Text('Ви впевнені, що хочете вийти зі свого профілю?'),
              actions: isLoggingOut
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Залишитись'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.dangerRed),
                        onPressed: () async {
                          setDialogState(() {
                            isLoggingOut = true;
                          });

                          try {
                            // Спочатку намагаємось вийти з Google, але не падаємо, якщо помилка
                            try {
                              await GoogleSignIn().signOut();
                            } catch (e) {
                              print("Помилка під час виходу з Google: $e");
                              // Ігноруємо помилку і продовжуємо, головне - вийти з Firebase
                            }

                            // Головна дія - вихід з Firebase Auth
                            await FirebaseAuth.instance.signOut();
                            
                            // Якщо ми дійшли сюди, значить вихід з Firebase був успішним
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const AuthScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          } catch (e) {
                            // Цей блок спрацює, ТІЛЬКИ ЯКЩО не вдалося вийти з FirebaseAuth
                            print("Критична помилка під час виходу з Firebase Auth: $e");
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Не вдалося вийти. Спробуйте ще раз.')),
                              );
                            }
                          }
                        },
                        child: const Text('Вийти'),
                      ),
                    ],
            );
          },
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
              // Адаптивні кольори для кнопки
              backgroundColor: Theme.of(context).cardColor,
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
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              title: Text(user?.displayName ?? 'Користувач', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(user?.email ?? 'немає email'),
              trailing: const Icon(FontAwesomeIcons.chevronRight, size: 16),
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

  // Widget _buildInterfaceCard() {
  //   return Consumer<ThemeProvider>(
  //     builder: (context, themeProvider, child) {
  //       return Card(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text('Інтерфейс', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //               const SizedBox(height: 8),
  //               SwitchListTile(
  //                 contentPadding: EdgeInsets.zero,
  //                 title: const Text('Темна тема'),
  //                 value: themeProvider.isDarkMode,
  //                 onChanged: (value) {
  //                   Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  //                 },
  //                 activeColor: AppColors.darkGreen,
  //               ),
  //               ListTile(
  //                 contentPadding: EdgeInsets.zero,
  //                 title: const Text('Сортування списків'),
  //                 trailing: DropdownButton<String>(
  //                   value: _sortValue,
  //                   underline: const SizedBox(),
  //                   items: <String>['За датою', 'За назвою']
  //                       .map<DropdownMenuItem<String>>((String value) {
  //                     return DropdownMenuItem<String>( value: value, child: Text(value) );
  //                   }).toList(),
  //                   onChanged: (String? newValue) {
  //                     if (newValue != null) {
  //                       setState(() { _sortValue = newValue; });
  //                     }
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildInterfaceCard() {
    return Consumer2<ThemeProvider, SortProvider>( // <-- Слухаємо два провайдери
      builder: (context, themeProvider, sortProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Інтерфейс', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // ... SwitchListTile для теми без змін
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Сортування списків'),
                  trailing: DropdownButton<SortOption>(
                    value: sortProvider.sortOption, // Беремо значення з провайдера
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: SortOption.byDate, child: Text('За датою')),
                      DropdownMenuItem(value: SortOption.byName, child: Text('За назвою')),
                    ],
                    onChanged: (SortOption? newValue) {
                      if (newValue != null) {
                        sortProvider.setSortOption(newValue); // Змінюємо через провайдер
                      }
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