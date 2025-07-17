import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 Sign up with Email & Password and save to Firestore
  Future<User?> signUpWithEmailAndSaveProfile({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Signup failed";
    }
  }

  // 🔑 Login with Email & Password
  Future<User?> loginWithUsernameOrEmail({
    required String identifier, // this can be username or email
    required String password,
  }) async {
    try {
      String email = identifier;

      // If the input doesn't contain '@', treat it as username
      if (!identifier.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('name', isEqualTo: identifier)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw 'No user found with this username';
        }

        final userData = querySnapshot.docs.first.data();
        email = userData['email'];
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed';
    } catch (e) {
      throw e.toString();
    }
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔁 Get current user
  User? get currentUser => _auth.currentUser;
}