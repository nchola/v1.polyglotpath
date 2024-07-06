import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lessons_screen.dart';

class LevelsScreen extends StatefulWidget {
  final String language;
  final String imagePath;

  LevelsScreen({required this.language, required this.imagePath});

  @override
  _LevelsScreenState createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  Future<bool> isFavorite(
      String userId, String levelId, String lessonId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('lessons')
        .doc('$levelId-$lessonId')
        .get();
    return snapshot.exists;
  }

  Future<void> toggleFavorite(String userId, String levelId, String lessonId,
      Map<String, dynamic> lessonData) async {
    final docRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('lessons')
        .doc('$levelId-$lessonId');
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set(lessonData);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to view levels.')),
      );
    }
    final userId = user.uid;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildHeaderText(),
            SizedBox(height: 10),
            Expanded(
              child: _buildLevelsContainer(context, userId, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('${widget.language} Levels'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: 'languageImage',
            child: Image.asset(widget.imagePath, width: 70, height: 70),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderText() {
    return Text(
      'Language Lessons',
      style: TextStyle(
        fontFamily: 'Quicksand',
        fontWeight: FontWeight.bold,
        fontSize: 19,
        color: Color.fromARGB(255, 84, 81, 81),
      ),
    );
  }

  Widget _buildLevelsContainer(
      BuildContext context, String userId, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('languages')
            .doc(widget.language.toLowerCase())
            .collection('levels')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No levels available.'));
          }

          final levels = snapshot.data!.docs;

          return ListView.builder(
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return _buildLevelTile(level, context, userId, isDarkMode, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildLevelTile(QueryDocumentSnapshot level, BuildContext context,
      String userId, bool isDarkMode, int index) {
    final levelId = level.id;
    Color containerColor = _getContainerColor(index, isDarkMode);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 4,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          levelId,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('languages')
                .doc(widget.language.toLowerCase())
                .collection('levels')
                .doc(levelId)
                .collection('lessons')
                .snapshots(),
            builder: (context, lessonSnapshot) {
              if (lessonSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (lessonSnapshot.hasError) {
                return Center(child: Text('Error: ${lessonSnapshot.error}'));
              }
              if (!lessonSnapshot.hasData ||
                  lessonSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No lessons available.'));
              }

              final lessons = lessonSnapshot.data!.docs;

              return Column(
                children: lessons.map((lesson) {
                  final lessonId = lesson.id;
                  return _buildLessonItem(context, userId, levelId, lesson);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, String userId, String levelId,
      DocumentSnapshot lesson) {
    return FutureBuilder<bool>(
      future: isFavorite(userId, levelId, lesson.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        bool isFav = snapshot.data ?? false;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonsScreen(
                  language: widget.language,
                  levelId: levelId,
                  lessonId: lesson.id,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title'],
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal,
                        ),
                      ),
                      Text(
                        lesson.id,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: isFav
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite_border, color: Colors.grey),
                  onPressed: () async {
                    await toggleFavorite(userId, levelId, lesson.id, {
                      'language': widget.language,
                      'levelId': levelId,
                      'lessonId': lesson.id,
                      'title': lesson['title'],
                      'userId': userId,
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getContainerColor(int index, bool isDarkMode) {
    if (index == 0) {
      return isDarkMode
          ? Color(0xFF00796B)
          : Color(0xFF40B59F); // Teal for Level 1
    } else if (index == 1) {
      return isDarkMode
          ? Color(0xFF757575)
          : Color(0xFFA29E9E); // Light grey for Level 2
    } else {
      return isDarkMode
          ? Color(0xFF00796B)
          : Color(0xFF40B59F); // Default color
    }
  }
}
