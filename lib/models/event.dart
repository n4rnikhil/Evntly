import 'package:cloud_firestore/cloud_firestore.dart';

// The core of the app. Everything revolves around these.
class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final DateTime registrationDeadline;
  final String location;
  final String registrationLink;
  final String imageUrl;
  final bool isFeatured;
  final bool isActive;
  final String submittedBy;
  final String? organizerName;
  final String? contactEmail;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.registrationDeadline,
    required this.location,
    required this.registrationLink,
    required this.imageUrl,
    this.isFeatured = false,
    this.isActive = true,
    required this.submittedBy,
    this.organizerName,
    this.contactEmail,
    this.status = 'pending',
    this.rejectionReason,
    required this.createdAt,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Other',
      date: (data['date'] as Timestamp).toDate(),
      registrationDeadline: (data['lastDateToRegister'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      registrationLink: data['registrationLink'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      submittedBy: data['submittedBy'] ?? '',
      organizerName: data['organizerName'],
      contactEmail: data['contactEmail'],
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'lastDateToRegister': Timestamp.fromDate(registrationDeadline),
      'location': location,
      'registrationLink': registrationLink,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'submittedBy': submittedBy,
      'organizerName': organizerName,
      'contactEmail': contactEmail,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
