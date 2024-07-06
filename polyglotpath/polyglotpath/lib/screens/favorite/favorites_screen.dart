import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:polyglotpath/services/theme_provider.dart';
import 'package:polyglotpath/screens/learning/lessons_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<void> toggleFavorite(String userId, String favoriteId) async {
    final docRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('lessons')
        .doc(favoriteId);

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.delete();
    }
    setState(() {}); // Rebuild widget to reflect changes in favorite status
  }

  void navigateToLesson(
      BuildContext context, String language, String levelId, String lessonId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonsScreen(
          language: language,
          levelId: levelId,
          lessonId: lessonId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (user == null) {
      return Center(child: Text('Please log in to view favorites.'));
    }
    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey.shade900 : Colors.teal,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 20.0,
              bottom:
                  20.0), // Added padding to avoid overlap with AppBar and BottomNavigationBar
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.5, // 30% of screen width for better padding
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('favorites')
                  .doc(userId)
                  .collection('lessons')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No favorites available.'));
                }
                final favorites = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    String language = favorite['language'];
                    String levelId = favorite['levelId'];
                    String lessonId = favorite['lessonId'];
                    String title = favorite['title'] ?? 'No title available';

                    return GestureDetector(
                      onTap: () => navigateToLesson(
                          context, language, levelId, lessonId),
                      child: _buildFavoriteItem(context, userId, favorite.id,
                          language, levelId, lessonId, title, themeProvider),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(
      BuildContext context,
      String userId,
      String favoriteId,
      String language,
      String levelId,
      String lessonId,
      String title,
      ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.teal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            '$language - $levelId - $lessonId',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Divider(
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
            thickness: 1,
          ),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(Icons.favorite, color: Colors.red),
              onPressed: () async {
                await toggleFavorite(userId, favoriteId);
              },
            ),
          ),
        ],
      ),
    );
  }
}
