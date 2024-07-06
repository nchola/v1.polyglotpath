import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:polyglotpath/screens/auth/sign_in_screen.dart';
import 'package:polyglotpath/screens/auth/sign_up_screen.dart';
import 'package:polyglotpath/widgets/splash_screen.dart';
import 'package:polyglotpath/screens/learning/detail_screen.dart';
import 'package:polyglotpath/screens/learning/levels_screen.dart';
import 'package:polyglotpath/widgets/main_screen.dart';
import 'package:polyglotpath/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Polyglotpath',
      theme: themeProvider.currentTheme,
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/sign-in': (context) => SignInScreen(),
        '/register': (context) => SignUpScreen(),
        '/home': (context) => MainScreen(),
        // '/detail': (context) => DetailScreen(),
        '/favorites': (context) => MainScreen(initialIndex: 1),
        '/community': (context) => MainScreen(initialIndex: 2),
        '/profile': (context) => MainScreen(initialIndex: 3),
        '/levels': (context) => LevelsScreen(
              language: '',
              imagePath: '',
            ),
      },
    );
  }
}
