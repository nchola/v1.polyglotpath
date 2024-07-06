import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polyglotpath/services/forum_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailPage extends StatefulWidget {
  final String forumName;
  final String postId;

  PostDetailPage({required this.forumName, required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isUploading = false;
  XFile? _commentImageFile;

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty && _commentImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment content or image is required')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? imageUrl;
    if (_commentImageFile != null) {
      try {
        imageUrl = await favoriteService.uploadXImage(_commentImageFile!);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
        setState(() {
          _isUploading = false;
        });
        return;
      }
    }

    await favoriteService.addComment(
        widget.forumName, widget.postId, _commentController.text,
        imageUrl: imageUrl);

    _commentController.clear();
    setState(() {
      _commentImageFile = null;
      _isUploading = false;
    });
  }

  Future<void> _pickCommentImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _commentImageFile = pickedFile;
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return timeago.format(date);
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('forums')
                .doc(widget.forumName)
                .collection('posts')
                .doc(widget.postId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var post = snapshot.data!;
              var postUserId = post['userId'];
              var postUserProfilePic = post['userProfilePic'];
              var postUserName = post['userName'];
              var postContent = post['content'];
              var postImageUrl = post['imageUrl'];
              var postTimestamp = post['timestamp'];
              var postLocation = post['location'] is GeoPoint
                  ? post['location'] as GeoPoint
                  : null;
              bool isOwner =
                  postUserId == FirebaseAuth.instance.currentUser?.uid;

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(postUserProfilePic),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              postUserName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              formatTimestamp(postTimestamp),
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 12,
                              ),
                            ),
                            if (postLocation != null)
                              GestureDetector(
                                onTap: () => _openMap(postLocation.latitude,
                                    postLocation.longitude),
                                child: Text(
                                  '${postLocation.latitude}, ${postLocation.longitude}',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () async {
                            await Share.share(
                                '$postContent - Shared from ${widget.forumName} forum');
                          },
                        ),
                        if (isOwner)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'Edit') {
                                _showEditPostDialog(
                                    widget.forumName, post.id, postContent);
                              } else if (value == 'Delete') {
                                await favoriteService.deletePost(
                                    widget.forumName, post.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      postContent,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (postImageUrl != null && postImageUrl.isNotEmpty)
                      SizedBox(height: 10),
                    if (postImageUrl != null && postImageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          postImageUrl,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.height * 0.23,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forums')
                  .doc(widget.forumName)
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index];
                    bool isOwner = comment['userId'] ==
                        FirebaseAuth.instance.currentUser?.uid;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(comment['userProfilePic']),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['userName'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    Text(
                                      formatTimestamp(comment['timestamp']),
                                      style: TextStyle(
                                        color:
                                            theme.textTheme.bodyMedium?.color,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      comment['content'],
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    if (comment['imageUrl'] != null &&
                                        comment['imageUrl'].isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            comment['imageUrl'],
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.23,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isOwner)
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'Edit') {
                                      _showEditCommentDialog(
                                          widget.forumName,
                                          widget.postId,
                                          comment.id,
                                          comment['content']);
                                    } else if (value == 'Delete') {
                                      favoriteService.deleteComment(
                                          widget.forumName,
                                          widget.postId,
                                          comment.id);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: 'Edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'Delete',
                                        child: Text('Delete'),
                                      ),
                                    ];
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_commentImageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(_commentImageFile!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _commentImageFile = null;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.inputDecorationTheme.border?.borderSide
                                  .color ??
                              Colors.grey,
                        ),
                      ),
                    ),
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: _pickCommentImage,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isUploading ? null : _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPostDialog(
      String forumName, String postId, String currentContent) {
    TextEditingController _editController =
        TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: _editController,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Edit your post'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await favoriteService.editPost(
                forumName,
                postId,
                _editController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(String forumName, String postId, String commentId,
      String initialContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _editController =
            TextEditingController(text: initialContent);

        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: 'Comment Content',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await favoriteService.editComment(
                    forumName, postId, commentId, _editController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
