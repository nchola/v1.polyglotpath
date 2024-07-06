import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:polyglotpath/services/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late GenerativeModel _model;
  final String _apiKey = 'AIzaSyAH4Mh-Vc3ZtSLP5Li25nZ-YDgrsAKDFiw';
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _initializeModel();
  }

  void _initializeModel() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    } else {
      print('API Key is empty');
      // Handle error: show dialog, etc.
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    // Get current user data from 'users' collection
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final currentUserData = currentUserDoc.data();

    // Save the user message to Firestore
    await FirebaseFirestore.instance.collection('chats').add({
      'text': userMessage,
      'senderId': user!.uid,
      'senderName':
          currentUserData?['username'] ?? 'Anonymous', // Null check added here
      'senderPhotoUrl': currentUserData?['photoURL'], // Null check added here
      'timestamp': Timestamp.now(),
      'isFromUser': true,
    });

    final content = [Content.text(userMessage)];
    final response = await _model.generateContent(content);

    // Save the AI response to Firestore
    await FirebaseFirestore.instance.collection('chats').add({
      'text': response.text ?? 'Error: No response from model',
      'senderId': 'gemini',
      'senderName': 'Gemini AI',
      'senderPhotoUrl': 'assets/gemini_ai_avatar.png',
      'timestamp': Timestamp.now(),
      'isFromUser': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with Gemini AI',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal, // Use the same color as other screens
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.black, Colors.grey.shade900]
                    : [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 249, 249, 249)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isFromUser = message['isFromUser'];
                          final isCurrentUser =
                              message['senderId'] == user!.uid;

                          // Filter untuk menampilkan hanya pesan dari pengguna atau Gemini AI
                          if (isFromUser || message['senderId'] == 'gemini') {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser)
                                    CircleAvatar(
                                      backgroundImage: message[
                                                  'senderPhotoUrl'] !=
                                              null
                                          ? NetworkImage(
                                              message['senderPhotoUrl'])
                                          : AssetImage(
                                                  'assets/default_profile_image.png')
                                              as ImageProvider,
                                    ),
                                  if (!isCurrentUser) SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? Colors.teal
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.15),
                                            spreadRadius: 4,
                                            blurRadius: 15,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message['senderName'] ??
                                                'Anonymous',
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isCurrentUser
                                                  ? Colors.white
                                                  : Colors.teal,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            message['text'] ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 18,
                                              color: isCurrentUser
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isCurrentUser) SizedBox(width: 10),
                                  if (isCurrentUser)
                                    CircleAvatar(
                                      backgroundImage: user!.photoURL != null
                                          ? NetworkImage(user!.photoURL!)
                                          : AssetImage(
                                                  'assets/default_profile_image.png')
                                              as ImageProvider,
                                    ),
                                ],
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            labelText: 'Type a message',
                            labelStyle: TextStyle(fontFamily: 'Quicksand'),
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
