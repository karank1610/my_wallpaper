import 'package:cloud_firestore/cloud_firestore.dart';

class PigeonUserDetails {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String role;
  final Timestamp createdAt;

  PigeonUserDetails({
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.role,
    required this.createdAt,
  });

  // Method to create the object from Firestore data
  factory PigeonUserDetails.fromFirestore(Map<String, dynamic> firestoreData) {
    return PigeonUserDetails(
      name: firestoreData['name'] ?? '',
      email: firestoreData['email'] ?? '',
      phone: firestoreData['phone'] ?? '',
      dob: firestoreData['dob'] ?? '',
      role: firestoreData['role'] ??
          'normal user', // Default role if not provided
      createdAt: firestoreData['createdAt'] is Timestamp
          ? firestoreData['createdAt']
          : Timestamp.now(), // Fallback if no timestamp is present
    );
  }

  // Method to convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
