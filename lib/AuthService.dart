import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credentials = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      return await _auth.signInWithCredential(credentials);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<String?> addUser({
    required String lat,
    required String lon,
  }) async {
    try {
      User? user = _auth.currentUser;
      
      if (user != null) {
        String email = user.email!;  
        CollectionReference users = FirebaseFirestore.instance.collection('student');
        await users.add({
          'email':email,
          'latitude': lat,
          'longitude': lon,
        });
        return 'success';
      } else {
        return 'User not authenticated';
      }
    } catch (e) {
      print(e.toString());
      return 'Error adding user';
    }
  }
}
