import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_iot/moduls/home_screen.dart';
import 'package:project_iot/moduls/login/login_screen.dart';
import 'package:project_iot/moduls/register/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_iot/settings_screen/settings_screen.dart';
import 'package:provider/provider.dart';
import 'core/app_provider/app_provider.dart';
import 'core/theme/theme.dart';
import 'firebase_options.dart';
import 'moduls/splash/splash_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _configureFirebaseAuth();

  runApp(ChangeNotifierProvider(
      create: (context) => AppProvider(), child: MyApp()));
}

Future<void> _configureFirebaseAuth() async {
  String configHost = "192.168.1.15";
  int configPort = 9099;
  var defaultHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  var host = configHost.isNotEmpty ? configHost : defaultHost;
  var port = configPort != 0 ? configPort : 9099;
  await FirebaseAuth.instance.useAuthEmulator(host, port);
  debugPrint('Using Firebase Auth emulator on: $host:$port');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, AppProvider, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => SplashScreen(),
          LoginScreen.routeName: (context) => LoginScreen(),
          RegisterScreen.routeName: (context) => RegisterScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
          SettingsScreen.routeName: (context) => SettingsScreen(),
        },
        navigatorObservers: [BotToastNavigatorObserver()],
        locale: AppProvider.currentLanguage,
        theme: ApplicationTheme.lightMode,
        builder: BotToastInit(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
    });
  }
}
