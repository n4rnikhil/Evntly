import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/event.dart';

// This is where all the event magic happens.
// Fetches, updates, and reviews.
class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload event poster to storage
  Future<String> uploadEventImage(File imageFile) async {
    try {
      final String fileName = 'event_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('event_posters').child(fileName);
      
      // Upload the file with a 10-second timeout
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.timeout(const Duration(seconds: 10));
      
      // Get the download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Storage Error: $e');
      // If storage fails or times out, we MUST fall back to a placeholder 
      // so the user isn't stuck.
      return 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&q=80&w=800';
    }
  }

  // Stream of live events for the home feed
  Stream<List<Event>> get liveEvents {
    return _db
        .collection('events')
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // Stream of pending events for admins
  Stream<List<Event>> get pendingEvents {
    return _db
        .collection('pending_events')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // Stream of total users count
  Stream<int> get totalUsersCount {
    return _db.collection('users').snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Submit an event (goes to review)
  Future<void> submitEvent(Event event) async {
    await _db.collection('pending_events').add(event.toMap());
  }

  // Admin: Approve event
  Future<void> approveEvent(String eventId, String adminUid) async {
    final doc = await _db.collection('pending_events').doc(eventId).get();
    final eventData = doc.data() as Map<String, dynamic>;
    
    // Update status in pending
    await _db.collection('pending_events').doc(eventId).update({
      'status': 'approved',
      'reviewedBy': adminUid,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    // Move to live events
    eventData['status'] = 'approved';
    await _db.collection('events').doc(eventId).set(eventData);
  }

  // Admin: Reject event
  Future<void> rejectEvent(String eventId, String reason) async {
    await _db.collection('pending_events').doc(eventId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  // User: Save/Unsave event
  Future<void> toggleSaveEvent(String userId, String eventId, bool isSaved) async {
    final userRef = _db.collection('users').doc(userId);
    if (isSaved) {
      await userRef.update({
        'savedEvents': FieldValue.arrayRemove([eventId])
      });
    } else {
      await userRef.update({
        'savedEvents': FieldValue.arrayUnion([eventId])
      });
    }
  }

  // User: Get my submissions
  Stream<List<Event>> mySubmissions(String userId) {
    return _db
        .collection('pending_events')
        .where('submittedBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // Admin: Delete event
  Future<void> deleteEvent(String eventId) async {
    // Delete from both collections to be safe
    await _db.collection('events').doc(eventId).delete();
    await _db.collection('pending_events').doc(eventId).delete();
  }
}
