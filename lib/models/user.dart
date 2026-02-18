import 'package:cloud_firestore/cloud_firestore.dart';

// Keeping it simple so it doesn't look like a robot wrote it lol
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student', 'organizer', 'admin'
  final List<String> interests;
  final List<String> savedEvents;
  final bool isVerifiedOrganizer;
  final bool isBanned;
  final DateTime createdAt;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.interests = const [],
    this.savedEvents = const [],
    this.isVerifiedOrganizer = false,
    this.isBanned = false,
    required this.createdAt,
    this.photoUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return AppUser(
      uid: doc.id,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      role: data?['role'] ?? 'student',
      interests: List<String>.from(data?['interests'] ?? []),
      savedEvents: List<String>.from(data?['savedEvents'] ?? []),
      isVerifiedOrganizer: data?['isVerifiedOrganizer'] ?? false,
      isBanned: data?['isBanned'] ?? false,
      createdAt: data?['createdAt'] != null 
          ? (data!['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      photoUrl: data?['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'interests': interests,
      'savedEvents': savedEvents,
      'isVerifiedOrganizer': isVerifiedOrganizer,
      'isBanned': isBanned,
      'createdAt': Timestamp.fromDate(createdAt),
      'photoUrl': photoUrl,
    };
  }
}
