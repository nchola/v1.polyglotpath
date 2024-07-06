// lib\screens\auth\sign_up_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:polyglotpath/services/firebase_auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) {
        _handleGoogleSignIn(account);
      }
    });
    _googleSignIn.signInSilently();
  }

  void _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    try {
      await _authService.signUpWithEmailAndPassword(email, password, username);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _authService.signInWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': googleUser.displayName,
        'email': googleUser.email,
      });

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/polyglotpath.jpeg', height: 250, width: 250),
              SizedBox(height: 20),
              Text(
                'Welcome to PolyglotPath!',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  height: 1.2,
                  color: Color(0xFF35C2C1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Create your account',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 1.2,
                  color: Color(0xFF8391A1),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF35C2C1),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/sign-in');
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: Color(0xFF8391A1),
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Color(0xFF35C2C1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Color(0xFFE8ECF4),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Or sign up with',
                    style: TextStyle(
                      color: Color(0xFF8391A1),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Color(0xFFE8ECF4),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  try {
                    await _googleSignIn.signIn();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Google sign-in failed. Please try again.')),
                    );
                  }
                },
                child: Container(
                  height: 50,
                  child: Center(
                    child: Image.asset(
                      'assets/google.png',
                      height: 65,
                      width: 45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
