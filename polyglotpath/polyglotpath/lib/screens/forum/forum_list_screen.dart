import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:polyglotpath/services/forum_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:polyglotpath/screens/forum/post_detail_screen.dart';

class ForumPage extends StatefulWidget {
  final String forumName;

  ForumPage({required this.forumName});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _postController = TextEditingController();
  XFile? _imageFile;
  bool _isUploading = false;
  bool _includeLocation = false;
  Position? _currentPosition;
  String? userProfilePic;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userProfilePic = userDoc['photoURL'];
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _addPost() async {
    if (_postController.text.isEmpty && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post content or image is required')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? imageUrl;
    if (_imageFile != null) {
      try {
        imageUrl = await favoriteService.uploadXImage(_imageFile!);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
        setState(() {
          _isUploading = false;
        });
        return;
      }
    }

    GeoPoint? location;
    if (_includeLocation && _currentPosition != null) {
      location =
          GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);
    }

    await favoriteService.addPost(widget.forumName, _postController.text,
        imageUrl: imageUrl, location: location);
    _postController.clear();
    setState(() {
      _imageFile = null;
      _isUploading = false;
      _includeLocation = false;
      _currentPosition = null;
    });
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    bool isPermissionGranted = await _requestLocationPermission();
    if (!isPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission is required')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _includeLocation = true;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Location acquired')));
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

  void _showFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forumName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forums')
                  .doc(widget.forumName)
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    bool isOwner = post['userId'] ==
                        FirebaseAuth.instance.currentUser?.uid;
                    GeoPoint? location = post['location'];
                    DateTime timestamp = post['timestamp'].toDate();

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(
                              forumName: widget.forumName,
                              postId: post.id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post['userProfilePic']),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['userName'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          timeago.format(timestamp),
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () async {
                                          await Share.share(
                                              '${post['content']} - Shared from ${widget.forumName} forum');
                                        },
                                      ),
                                      if (isOwner)
                                        PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            if (value == 'Edit') {
                                              _showEditPostDialog(
                                                  widget.forumName,
                                                  post.id,
                                                  post['content']);
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
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post['content'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (post['imageUrl'] != null &&
                                  post['imageUrl'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _showFullImage(post['imageUrl']),
                                    child: CachedNetworkImage(
                                      imageUrl: post['imageUrl'],
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                      width: 455,
                                      height: 260,
                                    ),
                                  ),
                                ),
                              if (location != null)
                                GestureDetector(
                                  onTap: () => _openMap(
                                      location.latitude, location.longitude),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_pin),
                                        const SizedBox(width: 5),
                                        Text(
                                          'View on Map',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Stack(
                      children: [
                        Container(
                          width: 505,
                          height: 360,
                          child: Image.network(
                            _imageFile!.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageFile = null;
                              });
                            },
                            child: Container(
                              color: Colors.black54,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userProfilePic != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(userProfilePic!),
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        decoration: const InputDecoration(
                          hintText: 'Write your post here...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: _getCurrentLocation,
                      color: _includeLocation ? Colors.blue : null,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _addPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        fixedSize: Size(118, 23),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
}
