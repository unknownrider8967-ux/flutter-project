import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/theme_provider.dart';
import 'data/services/database_service.dart';
import 'data/services/seed_service.dart';
import 'presentation/auth/screens/splash_screen.dart';
import 'presentation/auth/providers/auth_provider.dart';
import 'presentation/dashboard/providers/event_provider.dart';
import 'presentation/guest/providers/guest_provider.dart';
import 'presentation/task/providers/task_provider.dart';
import 'presentation/budget/providers/budget_provider.dart';
import 'presentation/auth/screens/login_screen.dart';
import 'presentation/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // sqflite_common_ffi is required on Linux and Windows desktop.
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await DatabaseService.instance.initialize();
  await SeedService.instance.seedIfNeeded();
  runApp(const SyncSphereApp());
}

class SyncSphereApp extends StatelessWidget {
  const SyncSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SyncSphere',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const SplashScreen(),
            routes: {
              '/dashboard': (context) => const DashboardScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
