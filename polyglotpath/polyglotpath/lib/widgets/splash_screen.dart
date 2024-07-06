//splash_screen.dart
import 'package:flutter/material.dart'; 
import 'dart:async'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:polyglotpath/utils/language_preferences.dart'; 

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LanguagePreferences _languagePreferences = LanguagePreferences();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); 
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        String? selectedLanguage = await _languagePreferences.getSelectedLanguage();
        if (selectedLanguage != null) {
          Navigator.pushReplacementNamed(
            context,
            '/detail',
            arguments: selectedLanguage,
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Handle error appropriately
      print('Error during navigation: $e');
      Navigator.pushReplacementNamed(context, '/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/polyglotpath.jpeg'),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
