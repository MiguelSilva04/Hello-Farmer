import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/store_service.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:harvestly/core/services/chat/chat_list_notifier.dart';
import 'package:harvestly/core/services/other/search_notifier.dart';
import 'package:harvestly/core/services/other/settings_notifier.dart';
import 'package:harvestly/pages/auth_page.dart';
import 'package:harvestly/pages/profile_page.dart';
import '../pages/chat_page.dart';
import '../pages/chat_settings_page.dart';
import '../pages/main_menu.dart';
import '../pages/new_chat_page.dart';
import '../pages/notification_page.dart';

import 'components/consumer/favorites_page.dart';
import 'components/producer/store_page.dart';
import 'core/notification/chat_notification_service.dart';
import '../pages/auth_or_app_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/auth/notification_notifier.dart';
import 'core/services/other/bottom_navigation_notifier.dart';
import 'core/services/other/manage_section_notifier.dart';
import 'pages/settings_page.dart';
import 'utils/app_routes.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/other/preferences_notifier.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_PT', null);
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatListNotifier()),
        ChangeNotifierProvider(create: (_) => ChatNotificationService()),
        ChangeNotifierProvider<ChatService>(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => BottomNavigationNotifier()),
        ChangeNotifierProvider(create: (_) => ManageSectionNotifier()),
        ChangeNotifierProvider(create: (_) => SettingsNotifier()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => StoreService.instance),
        ChangeNotifierProvider(create: (_) => PreferencesNotifier()),
        ChangeNotifierProvider(create: (_) => SearchNotifier()),
        ChangeNotifierProvider(create: (_) => NotificationNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<PreferencesNotifier>(context);
    final preferences = Provider.of<PreferencesNotifier>(context);
    return MaterialApp(
      title: 'Harvestly',
      locale: preferences.currentLocale,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color.fromRGBO(232, 229, 218, 1),
        textTheme: ThemeData.light().textTheme
            .apply(fontFamily: 'Poppins')
            .copyWith(
              titleLarge: const TextStyle(
                fontSize: 38,
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              displayLarge: const TextStyle(
                fontSize: 44,
                fontFamily: 'Poppins',
                color: Color.fromRGBO(155, 202, 184, 1),
                fontWeight: FontWeight.bold,
              ),
              titleMedium: const TextStyle(
                fontSize: 22,
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
        colorScheme: ColorScheme.fromSeed(
          primary: const Color.fromRGBO(66, 139, 109, 1),
          surface: const Color.fromRGBO(42, 129, 94, 1),
          surfaceDim: const Color(0xFFDEF2EA),
          secondary: Colors.white,
          scrim: Colors.yellow,
          secondaryFixed: const Color.fromARGB(255, 82, 82, 82),
          tertiaryFixedDim: const Color.fromARGB(255, 199, 243, 226),
          tertiary: const Color.fromRGBO(155, 202, 184, 1),
          onTertiary: Colors.green[100],
          onTertiaryFixed: Colors.green[800],
          tertiaryFixed: Colors.black,
          onTertiaryFixedVariant: Colors.grey,
          onTertiaryContainer: Colors.grey[200],
          inverseSurface: const Color.fromRGBO(91, 152, 134, 1),
          inversePrimary: const Color.fromRGBO(40, 87, 70, 1),
          onInverseSurface: const Color.fromRGBO(232, 247, 238, 1),
          seedColor: Colors.purple,
          outline: Colors.orange.shade50,
          surfaceContainerLowest: const Color.fromRGBO(168, 218, 184, 1),
          surfaceContainerLow: const Color.fromRGBO(222, 246, 228, 1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(42, 129, 94, 1),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color.fromRGBO(48, 48, 48, 1),
        textTheme: ThemeData.dark().textTheme
            .apply(fontFamily: 'Poppins')
            .copyWith(
              titleLarge: const TextStyle(
                fontSize: 38,
                fontFamily: 'Poppins',
                color: Color.fromRGBO(155, 202, 184, 1),
                fontWeight: FontWeight.bold,
              ),
              displayLarge: const TextStyle(
                fontSize: 44,
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: const TextStyle(
                fontSize: 22,
                fontFamily: 'Poppins',
                color: Color.fromRGBO(155, 202, 184, 1),
                fontWeight: FontWeight.w600,
              ),
            ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
          primary: const Color.fromRGBO(42, 129, 94, 1),
          secondary: Colors.black,
          secondaryFixed: Colors.white,
          tertiary: const Color.fromRGBO(91, 152, 134, 1),
          inverseSurface: const Color.fromRGBO(155, 202, 184, 1),
          inversePrimary: const Color.fromRGBO(232, 229, 218, 1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(64, 64, 64, 1),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeNotifier.themeMode,
      // home: const AuthOrAppPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        AppRoutes.AUTH_OR_APP_PAGE: (ctx) => AuthOrAppPage(),
        AppRoutes.AUTH_PAGE: (ctx) => AuthPage(),
        AppRoutes.MAIN_MENU: (ctx) => MainMenu(),
        AppRoutes.CHAT_PAGE: (ctx) => ChatPage(),
        AppRoutes.SETTINGS_PAGE: (ctx) => SettingsPage(),
        AppRoutes.CHAT_SETTINGS_PAGE: (ctx) => ChatSettingsPage(),
        AppRoutes.NEW_CHAT_PAGE: (ctx) => NewChatPage(),
        AppRoutes.NOTIFICATION_PAGE: (ctx) => NotificationsPage(),
        AppRoutes.PROFILE_PAGE: (ctx) => ProfilePage(),
        AppRoutes.FAVORITES_PAGE: (ctx) => FavoritesPage(),
        AppRoutes.STORE_PAGE: (ctx) => StorePage(),
      },
    );
  }
}
