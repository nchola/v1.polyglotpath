import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  final int _limit = 20; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  List<DocumentSnapshot> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMoreNotifications();
      }
    });
  }

  Future<void> _fetchNotifications() async {
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('timestamp', descending: true)
        .limit(_limit);

    QuerySnapshot querySnapshot = await query.get();
    _notifications = querySnapshot.docs;

    if (_notifications.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMoreNotifications() async {
    if (_isLoading || _lastDocument == null) return;

    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_limit);

    QuerySnapshot querySnapshot = await query.get();
    _notifications.addAll(querySnapshot.docs);

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void sendNotification(String userId, String message) {
    FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notifications', style: GoogleFonts.montserrat()),
        ),
        body: Center(child: Text('You are not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.montserrat()),
      ),
      body: _isLoading && _notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(child: Text('No notifications found'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    var notification = _notifications[index];
                    return ListTile(
                      title: Text(notification['message']),
                      subtitle: Text(
                        notification['timestamp'].toDate().toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: notification['isRead']
                          ? null
                          : Icon(Icons.circle, color: Colors.blue, size: 10),
                      onTap: () {
                        notification.reference.update({'isRead': true});
                      },
                    );
                  },
                ),
    );
  }
}
