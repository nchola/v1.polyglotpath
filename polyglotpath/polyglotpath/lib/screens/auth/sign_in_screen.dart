import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:polyglotpath/services/firebase_auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  void _signIn() async {
    final emailOrUsername = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrUsername.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Email/Username and password cannot be empty.')),
      );
      return;
    }

    try {
      await _authService.signInWithEmailAndPassword(emailOrUsername, password);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email/username.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          default:
            errorMessage = 'Sign in failed. Please try again.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your email to reset your password.')),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/google-signin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'idToken': idToken!,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  height: 1.4,
                  color: Color(0xFF35C2C1),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Login to your account',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                  height: 1.2,
                  color: Color(0xFF8391A1),
                ),
              ),
              SizedBox(height: 22),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email/Username',
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: Text('Forgot Password?'),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E232C),
                  fixedSize: Size(168, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 3,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text('Or Login with'),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _googleSignIn.signIn(),
                    child: Image.asset(
                      'assets/google.png',
                      height: 70,
                      width: 70,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: Text(
                      'Register Now',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
