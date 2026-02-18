import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// Just a quick helper to upload images to Firebase Storage.
// I use UUIDs to keep the filenames unique.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadEventPoster(File image) async {
    try {
      final fileName = '${const Uuid().v4()}.jpg';
      final ref = _storage.ref().child('event_posters').child(fileName);
      
      final uploadTask = await ref.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Image upload failed: $e');
      rethrow;
    }
  }
}
