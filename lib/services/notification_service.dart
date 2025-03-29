// lib/services/notification_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  // Add a notification to the user's notification collection
  static Future<void> addNotification(
    String userId, // User ID of the recipient
    String title,
    String message, {
    String? wallpaperKey, // Store wallpaperKey
  }) async {
    final notificationRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc();

    await notificationRef.set({
      'title': title,
      'message': message,
      'wallpaperKey': wallpaperKey ?? "", // Ensure wallpaperKey is not null
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    print("Notification sent to user: $userId");
  }
}
