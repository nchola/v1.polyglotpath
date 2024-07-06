import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class favoriteService {
  static Future<String> uploadImage(File imageFile) async {
    try {
      String filePath = 'forums/${DateTime.now()}.png';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  static Future<String> uploadXImage(XFile imageFile) async {
    try {
      String filePath = 'forums/${DateTime.now()}.png';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask =
          storageReference.putData(await imageFile.readAsBytes());
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  static Future<void> addPost(String forumName, String content,
      {String? imageUrl, GeoPoint? location}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(forumName)
            .collection('posts')
            .add({
          'imageUrl': imageUrl ?? '',
          'content': content,
          'userName': user.displayName ?? 'Anonymous',
          'userProfilePic': user.photoURL ?? '',
          'timestamp': Timestamp.now(),
          'userId': user.uid,
          'location': location,
        });
      } catch (e) {
        throw Exception('Error adding post: $e');
      }
    }
  }

  static Future<void> deletePost(String forumName, String postId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot post = await FirebaseFirestore.instance
          .collection('forums')
          .doc(forumName)
          .collection('posts')
          .doc(postId)
          .get();

      if (post['userId'] == user.uid) {
        try {
          await FirebaseFirestore.instance
              .collection('forums')
              .doc(forumName)
              .collection('posts')
              .doc(postId)
              .delete();
        } catch (e) {
          throw Exception('Error deleting post: $e');
        }
      } else {
        throw Exception('You do not have permission to delete this post');
      }
    }
  }

  static Future<void> editPost(
      String forumName, String postId, String newContent) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot post = await FirebaseFirestore.instance
          .collection('forums')
          .doc(forumName)
          .collection('posts')
          .doc(postId)
          .get();

      if (post['userId'] == user.uid) {
        try {
          await FirebaseFirestore.instance
              .collection('forums')
              .doc(forumName)
              .collection('posts')
              .doc(postId)
              .update({'content': newContent});
        } catch (e) {
          throw Exception('Error editing post: $e');
        }
      } else {
        throw Exception('You do not have permission to edit this post');
      }
    }
  }

  static Future<void> addComment(String forumName, String postId, String text,
      {String? imageUrl}) async {
    await FirebaseFirestore.instance
        .collection('forums')
        .doc(forumName)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'userName': FirebaseAuth.instance.currentUser!.displayName,
      'userProfilePic': FirebaseAuth.instance.currentUser!.photoURL,
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
    });
  }

  static Future<void> editComment(
      String forumName, String postId, String commentId, String content) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(forumName)
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'content': content,
          'userName': user.displayName ?? 'Anonymous',
          'userProfilePic': user.photoURL ?? '',
          'timestamp': Timestamp.now(),
          'userId': user.uid,
        });
      } catch (e) {
        throw Exception('Error editing comment: $e');
      }
    }
  }

  static Future<void> deleteComment(
      String forumName, String postId, String commentId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot comment = await FirebaseFirestore.instance
          .collection('forums')
          .doc(forumName)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (comment['userId'] == user.uid) {
        try {
          await FirebaseFirestore.instance
              .collection('forums')
              .doc(forumName)
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .delete();
        } catch (e) {
          throw Exception('Error deleting comment: $e');
        }
      } else {
        throw Exception('You do not have permission to delete this comment');
      }
    }
  }
}
