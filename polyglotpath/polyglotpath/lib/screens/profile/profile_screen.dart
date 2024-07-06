import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polyglotpath/screens/profile/notification_screen.dart';
import 'package:polyglotpath/services/firebase_auth_service.dart';
import 'package:polyglotpath/screens/profile/edit_profile_screen.dart';
import 'package:polyglotpath/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:polyglotpath/screens/profile/chat_screen.dart';
import 'package:polyglotpath/screens/favorite/favorites_screen.dart';
import 'package:polyglotpath/screens/profile/feedback_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? imageFile;
  late User? user;
  String? username;
  final TextEditingController _usernameController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
          _usernameController.text = username!;
        });
      });
    }
    _listenForNotifications();
  }

  void _listenForNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user!.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        _showNotification(doc['message']);
      }
    });
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      await _uploadProfilePicture(pickedFile);
    }
  }

  Future<void> _uploadProfilePicture(XFile file) async {
    String? downloadUrl = await FirebaseAuthService.uploadImage(file);
    if (downloadUrl != null) {
      await user?.updateProfile(photoURL: downloadUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'photoURL': downloadUrl});
      await _updateProfilePictureInPostsAndComments(downloadUrl);
      setState(() {
        user = FirebaseAuth.instance.currentUser; // Refresh the user state
      });
    }
  }

  Future<void> _updateProfilePictureInPostsAndComments(
      String downloadUrl) async {
    // Update in posts
    try {
      var postsQuery = await FirebaseFirestore.instance
          .collectionGroup('posts')
          .where('userId', isEqualTo: user!.uid)
          .get();
      for (var post in postsQuery.docs) {
        await post.reference.update({'userProfilePic': downloadUrl});
      }

      // Update in comments
      var commentsQuery = await FirebaseFirestore.instance
          .collectionGroup('comments')
          .where('userId', isEqualTo: user!.uid)
          .get();
      for (var comment in commentsQuery.docs) {
        await comment.reference.update({'userProfilePic': downloadUrl});
      }
    } catch (e) {
      print('Error updating profile picture in posts and comments: $e');
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuthService().signOut();
    Navigator.of(context).pushReplacementNamed('/sign-in');
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.isNotEmpty && user != null) {
      try {
        await FirebaseAuthService.updateUsername(
            user!.uid, _usernameController.text.trim());
        setState(() {
          username = _usernameController.text.trim();
        });
      } catch (e) {
        print('Error updating username: $e');
      }
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        username = result['username'];
        // Update other data if needed
      });
    }
  }

  void _navigateToChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()),
    );
  }

  void _navigateToFeedBackScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedbackScreen()),
    );
  }

  void _navigateToNotificationsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,
                color: isDarkMode ? Colors.white : Colors.black),
            onPressed: _navigateToNotificationsScreen,
          ),
        ],
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: user?.photoURL != null
                                    ? NetworkImage(user!.photoURL!)
                                    : null,
                                child: user?.photoURL == null
                                    ? Icon(
                                        Icons.person,
                                        size: 40,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          child: Text(
                            username ?? 'Username',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(color: isDarkMode ? Colors.white54 : Colors.black54),
                  SizedBox(height: 10),
                  Text(
                    'Preferences',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildPreferenceCard(
                          icon: Icons.edit,
                          text: 'Edit Profile',
                          onTap: _navigateToEditProfile,
                          isDarkMode: isDarkMode,
                        ),
                        _buildPreferenceCard(
                          icon: Icons.favorite,
                          text: 'Favorite',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FavoritesScreen()),
                            );
                          },
                          isDarkMode: isDarkMode,
                        ),
                        _buildPreferenceCard(
                          icon: Icons.dark_mode,
                          text: 'Darkmode',
                          onTap: () {
                            themeProvider.toggleTheme();
                          },
                          isDarkMode: isDarkMode,
                        ),
                        _buildPreferenceCard(
                          icon: Icons.feedback,
                          text: 'Feedback',
                          onTap: _navigateToFeedBackScreen,
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 2),
                        FractionallySizedBox(
                          widthFactor: 0.3,
                          child: ElevatedButton(
                            onPressed: _signOut,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 3),
                                Text('Sign-out'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FloatingActionButton(
            onPressed: _navigateToChatScreen,
            backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.teal,
            child: Icon(
              Icons.chat,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70.0),
            child: Text(
              'Chat',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      required bool isDarkMode}) {
    return Card(
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
