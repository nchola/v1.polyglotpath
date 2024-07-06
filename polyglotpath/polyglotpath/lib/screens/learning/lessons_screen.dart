import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polyglotpath/screens/profile/chat_screen.dart';

class LessonsScreen extends StatefulWidget {
  final String language;
  final String levelId;
  final String lessonId;

  LessonsScreen({
    required this.language,
    required this.levelId,
    required this.lessonId,
  });

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to view the lesson.')),
      );
    }

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.language} ${widget.levelId} - ${widget.lessonId}'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('languages')
            .doc(widget.language.toLowerCase())
            .collection('levels')
            .doc(widget.levelId)
            .collection('lessons')
            .doc(widget.lessonId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No lesson data available.'));
          }
          final lessonData = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: Container(
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLessonTitleCard(lessonData, isDarkMode),
                    SizedBox(height: 20),
                    _buildLessonDescriptionCard(lessonData, isDarkMode),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        },
        child: Icon(Icons.chat),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildLessonTitleCard(
      Map<String, dynamic> lessonData, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        lessonData['title'] ?? 'No title available',
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildLessonDescriptionCard(
      Map<String, dynamic> lessonData, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        lessonData['description'] ?? 'No description available',
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 18,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLessonContentCard(
      Map<String, dynamic> lessonData, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
    );
  }
}
