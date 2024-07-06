import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyglotpath/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';
import 'package:polyglotpath/services/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late User? user;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool _obscureText = true;
  bool _confirmObscureText = true;

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
          _usernameController.text = doc.data()?['username'] ?? '';
          _emailController.text = user!.email ?? '';
          _phoneController.text = doc.data()?['phone'] ?? '';
        });
      }).catchError((error) {
        print('Error fetching user data: $error');
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isNotEmpty && user != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // Update username
        await FirebaseAuthService.updateUsername(
            user!.uid, _usernameController.text.trim());

        // Update email
        if (_emailController.text.isNotEmpty) {
          await user!.updateEmail(_emailController.text.trim());
        }

        // Update password
        if (_passwordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text) {
          await user!.updatePassword(_passwordController.text.trim());
        } else if (_passwordController.text !=
            _confirmPasswordController.text) {
          // Handle password mismatch
          throw Exception('Passwords do not match');
        }

        // Update phone number
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'phone': _phoneController.text.trim()});

        Navigator.of(context).pop({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        }); // Kembalikan data yang diperbarui ke layar sebelumnya
      } catch (e) {
        print('Error updating profile: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
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
          'Edit Profile',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 20),
                  Divider(color: isDarkMode ? Colors.white54 : Colors.black54),
                  SizedBox(height: 10),
                  Text(
                    'Change password ',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _confirmObscureText,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmObscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmObscureText = !_confirmObscureText;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: isDarkMode
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: isDarkMode
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                    child: Text(
                      'Update Profile',
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
