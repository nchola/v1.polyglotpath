import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadImage(XFile file) async {
    try {
      String fileName = path.basename(file.path);
      Reference ref = _storage.ref().child('images').child('/$fileName');
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(await file.readAsBytes());
      } else {
        uploadTask = ref.putFile(io.File(file.path));
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error signing in with email and password: $e');
      throw e;
    }
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await userCredential.user!.updateDisplayName(username);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
      });
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: $e');
      throw e;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with credential: $e');
      throw e;
    }
  }

  static Future<void> updateUsername(String userId, String newUsername) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newUsername);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'username': newUsername});
      }
    } catch (e) {
      print('Error updating username: $e');
      throw e;
    }
  }
}
