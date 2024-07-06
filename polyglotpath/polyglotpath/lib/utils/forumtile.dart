// forumtile.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForumTile extends StatelessWidget {
  final String title;
  final String forumName;
  final String flagAsset;
  final VoidCallback onTap;

  ForumTile({
    required this.title,
    required this.forumName,
    required this.flagAsset,
    required this.onTap,
  });

  Future<int> getPostCount(String forumName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('forums')
          .doc(forumName)
          .collection('posts')
          .get();
      return snapshot.size;
    } catch (e) {
      print('Failed to load post count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getPostCount(forumName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildTile(context, 'Loading post count...', flagAsset);
        } else if (snapshot.hasError) {
          return _buildTile(context, 'Error loading post count', flagAsset);
        } else {
          return _buildTile(context, '${snapshot.data} posts', flagAsset);
        }
      },
    );
  }

  Widget _buildTile(BuildContext context, String subtitle, String flagAsset) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_downward, color: Colors.green),
          Icon(Icons.arrow_upward, color: Colors.green),
        ],
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Image.asset(flagAsset, width: 50),
      onTap: onTap,
    );
  }
}
