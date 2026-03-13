import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'run_service.dart';
import 'purchase_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeService();
  PurchaseService().initialize();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  final savedLanguage = prefs.getString('languageCode');
  if (savedLanguage != null) {
    localeNotifier.value = Locale(savedLanguage);
  }

  runApp(const AnotherRunnerApp());
}

class AnotherRunnerApp extends StatelessWidget {
  const AnotherRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (_, Locale? currentLocale, __) {
            return MaterialApp(
              title: 'YARA',
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: currentLocale,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: currentMode,
              home: StreamBuilder(
                stream: AuthService().authStateChanges,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    return const HomeScreen();
                  }
                  return const LoginScreen();
                },
              ),
            );
          },
        );
      },
    );
  }
}