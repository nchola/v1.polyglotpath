import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyglotpath/screens/learning/levels_screen.dart';
import 'package:polyglotpath/widgets/language_option.dart';
import 'utils/language_preferences.dart';
import 'package:provider/provider.dart';
import 'package:polyglotpath/services/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LanguagePreferences _languagePreferences = LanguagePreferences();
  String _selectedLanguage = '';
  String _selectedImagePath = '';

  late User? user;
  String? username;
  String? photoURL;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((doc) {
        setState(() {
          username = doc['username'];
          photoURL = user!.photoURL;
        });
      });
    }
  }

  void _onLanguageSelected(
      BuildContext context, String language, String imagePath) async {
    setState(() {
      _selectedLanguage = language;
      _selectedImagePath = imagePath;
    });
    await _languagePreferences.saveSelectedLanguage(language);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelsScreen(
            language: _selectedLanguage, imagePath: _selectedImagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.black, Colors.grey.shade900]
                    : [Colors.white, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 5)
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Hallo ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Color.fromARGB(255, 53, 53, 53)),
                                ),
                                Text(
                                  username ?? 'User',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Color.fromARGB(255, 53, 53, 53)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: photoURL != null
                                ? NetworkImage(photoURL!)
                                : AssetImage('assets/default_profile_image.png')
                                    as ImageProvider,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Welcome to ',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : Color.fromARGB(255, 0, 0, 0)),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Polyglotpath',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 30, 162, 153)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Choose the language you want to learn:',
                          style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Color.fromARGB(255, 0, 0, 0)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _onLanguageSelected(
                                context, 'English', 'assets/english.png'),
                            child: LanguageOption(
                                imagePath: 'assets/english.png',
                                language: 'English'),
                          ),
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _onLanguageSelected(
                                context, 'Japanese', 'assets/japan.png'),
                            child: LanguageOption(
                                imagePath: 'assets/japan.png',
                                language: 'Japanese'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _onLanguageSelected(
                                context, 'Korean', 'assets/korea.png'),
                            child: LanguageOption(
                                imagePath: 'assets/korea.png',
                                language: 'Korean'),
                          ),
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _onLanguageSelected(
                                context, 'Russian', 'assets/russia.png'),
                            child: LanguageOption(
                                imagePath: 'assets/russia.png',
                                language: 'Russian'),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedLanguage.isNotEmpty &&
                              _selectedImagePath.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LevelsScreen(
                                    language: _selectedLanguage,
                                    imagePath: _selectedImagePath),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please select a language first.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          fixedSize: Size(168, 53),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: Text(
                          'Start!',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.2,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
