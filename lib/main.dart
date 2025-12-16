
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shop_helper_app/providers/shopping_lists_provider.dart';
import 'package:shop_helper_app/providers/sort_provider.dart';
import 'package:shop_helper_app/providers/theme_provider.dart';
import 'package:shop_helper_app/screens/auth_screen.dart';
import 'package:shop_helper_app/screens/list_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_colors.dart';
import 'firebase_options.dart';
import 'dart:ui'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('uk_UA', null);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://29d4af99198835b8ca7fb2f401b8b862@o4510363177189376.ingest.de.sentry.io/4510363184988240';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ShoppingListsProvider()),
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
        ChangeNotifierProvider(create: (ctx) => SortProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          
          // Базова світла тема
          final lightTheme = ThemeData(
            useMaterial3: true,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.darkGreen,
              brightness: Brightness.light,
              surface: AppColors.cardWhite, 
              background: AppColors.backgroundGrey, 
            ),
          );

          // Базова темна тема
          final darkTheme = ThemeData(
            useMaterial3: true,
            fontFamily: 'Inter',
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.darkGreen,
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E), 
              background: const Color(0xFF121212), 
            ),
          );

          return MaterialApp(
            title: 'ShopHelper',
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('uk', 'UA'), // Українська
              Locale('en', 'US'), // Англійська (як запасний варіант)
            ],
            locale: const Locale('uk', 'UA'),

            scrollBehavior: MyCustomScrollBehavior(), 

            theme: lightTheme.copyWith(
              scaffoldBackgroundColor: lightTheme.colorScheme.background,
              cardTheme: lightTheme.cardTheme.copyWith(
                elevation: 1,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            
            darkTheme: darkTheme.copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212), // Дуже темний фон сторінки

              // Робимо AppBar темним за замовчуванням
              appBarTheme: darkTheme.appBarTheme.copyWith(
                backgroundColor: const Color(0xFF1E1E1E), // Колір карток
                elevation: 1,
              ),
              
              // Робимо BottomAppBar темним за замовчуванням
              bottomAppBarTheme: darkTheme.bottomAppBarTheme.copyWith(
                color: const Color(0xFF1E1E1E),
              ),

              // Налаштування для карток, щоб вони мали товстий світлий контур
              cardTheme: darkTheme.cardTheme.copyWith(
                elevation: 0,
                color: const Color(0xFF1E1E1E), // Темний колір для карток
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  // Додаємо товстіший світлий контур
                  side: BorderSide(color: Color(0xFF444444), width: 2.0), 
                ),
              ),

              // TabBar має бути на темному фоні, тому текст робимо світлим
              tabBarTheme: const TabBarThemeData(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: AppColors.darkGreen,
              ),

              // Кнопки залишаються яскравими
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  backgroundColor: AppColors.primaryGreen,
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
              ),
            ),
            
            debugShowCheckedModeBanner: false,
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (userSnapshot.hasData) {
                  return const ListScreen();
                }
                return const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,    // Дозволяє тягнути мишкою
        PointerDeviceKind.trackpad, // Дозволяє тягнути тачпадом
      };
}