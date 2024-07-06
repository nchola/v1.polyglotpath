//polyglotpath\lib\models\post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String forumId;
  final String content;
  final String userName;
  final String userProfilePic;
  final Timestamp timestamp;
  final String userId;

  Post({
    required this.id,
    required this.forumId,
    required this.content,
    required this.userName,
    required this.userProfilePic,
    required this.timestamp,
    required this.userId,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      forumId: doc['forumId'],
      content: doc['content'],
      userName: doc['userName'],
      userProfilePic: doc['userProfilePic'],
      timestamp: doc['timestamp'],
      userId: doc['userId'],
    );
  }
}
