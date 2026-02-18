import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

// This handles all the login/register logic. 
// I tried to keep it clean but Firebase can be a bit messy sometimes.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of current user role/data
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        final isAdminEmail = user.email == 'admin@evntly.app' || user.email == 'nikhilnuguri2007@gmail.com';
        final newUser = AppUser(
          uid: user.uid,
          name: user.displayName ?? 'Admin User',
          email: user.email ?? '',
          role: isAdminEmail ? 'admin' : 'student',
          createdAt: DateTime.now(),
        );
        
        // Actually save it to Firestore so security rules work!
        if (isAdminEmail) {
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
        }
        return newUser;
      }
      
      return AppUser.fromFirestore(doc);
    });
  }

  Future<AppUser?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _db.collection('users').doc(credential.user!.uid).get();
      
      if (!doc.exists) {
        return AppUser(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? 'User',
          email: email,
          role: (email == 'admin@evntly.app' || email == 'nikhilnuguri2007@gmail.com') ? 'admin' : 'student',
          createdAt: DateTime.now(),
        );
      }
      
      return AppUser.fromFirestore(doc);
    } catch (e) {
      print('Login failed: $e');
      rethrow;
    }
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
    required List<String> interests,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final newUser = AppUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: 'student', // default
        interests: interests,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(newUser.uid).set(newUser.toMap());
      return newUser;
    } catch (e) {
      print('Registration failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Admin logic (hardcoded check for safety)
  bool isAdmin(AppUser? user) {
    // Adding nikhilnuguri2007@gmail.com as temp admin for testing
    return user?.role == 'admin' || 
           user?.email == 'admin@evntly.app' || 
           user?.email == 'nikhilnuguri2007@gmail.com';
  }
}
