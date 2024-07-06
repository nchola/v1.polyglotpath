import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:polyglotpath/services/theme_provider.dart';
import 'package:provider/provider.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _sendFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _feedbackController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      // Upload the image if exists
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadFeedbackImage(_imageFile!);
      }

      // Save feedback to Firestore
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': user.uid,
        'feedback': _feedbackController.text,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.now(),
      });

      // Clear input
      _feedbackController.clear();
      setState(() {
        _imageFile = null;
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback sent successfully!')),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in feedback text.')),
      );
    }
  }

  Future<String?> _uploadFeedbackImage(XFile file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      Reference ref =
          FirebaseStorage.instance.ref().child('feedback/$fileName');

      if (kIsWeb) {
        // Web specific upload
        UploadTask uploadTask = ref.putData(await file.readAsBytes());
        TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      } else {
        // Mobile specific upload
        UploadTask uploadTask = ref.putFile(io.File(file.path));
        TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Send Feedback',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? Colors.black : Colors.teal,
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            )
          else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Describe your issue or feedback:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isDarkMode ? Colors.grey.shade800 : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_imageFile != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: kIsWeb
                            ? Image.network(
                                _imageFile!.path,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                io.File(_imageFile!.path),
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                      ),
                    Spacer(),
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.add_photo_alternate,
                                        size: 40),
                                    onPressed: _pickImage,
                                  ),
                                  Text('Add Image')
                                ],
                              ),
                              SizedBox(width: 50),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.send, size: 40),
                                    onPressed: _sendFeedback,
                                  ),
                                  Text('Send Feedback')
                                ],
                              ),
                            ],
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
    );
  }
}
