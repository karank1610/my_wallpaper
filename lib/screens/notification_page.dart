import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _markNotificationsAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black, // Dark Theme
      body: StreamBuilder(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Failed to load notifications.",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildNoNotificationsUI();
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];

              // Handle missing fields to prevent errors
              String title = notification['title'] ?? 'Notification';
              String message = notification['message'] ?? '';
              String? imageUrl = (notification.data() as Map<String, dynamic>?)
                          ?.containsKey('imageUrl') ==
                      true
                  ? notification['imageUrl']
                  : null;

              Timestamp? timestamp = notification['timestamp'];
              bool isRead = notification['read'] ?? false;

              return ListTile(
                leading: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image,
                                  color: Colors.white70),
                        ),
                      )
                    : const Icon(Icons.notifications, color: Colors.white70),
                title: Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(
                  "${message} • ${timestamp != null ? timeago.format(timestamp.toDate()) : 'Just now'}",
                  style: const TextStyle(color: Colors.white54),
                ),
                tileColor: isRead
                    ? Colors.black
                    : Colors.grey[900], // Highlight unread
                onTap: () => _markAsRead(notification.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Widget _buildNoNotificationsUI() {
    return Center(
      // ✅ Ensures content is centered
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.center, // ✅ Center aligns content
        children: [
          Icon(Icons.notifications_off, color: Colors.white54, size: 80),
          const SizedBox(height: 20),
          const Text(
            "No notifications yet.",
            style: TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center, // ✅ Centers text
          ),
          const SizedBox(height: 10),
          const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 30), // ✅ Prevents overflow
            child: Text(
              "We'll notify you when something important happens.",
              style: TextStyle(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center, // ✅ Centers text
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markNotificationsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }
}
