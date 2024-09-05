import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authservice {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential?> loginWithGoogle() async{
    try{
      print("hello");
      final googleUser = await GoogleSignIn().signIn();
      print("hello ${googleUser}");
      final googleAuth = await googleUser?.authentication;
      print("hello ${googleAuth}");
      final crediantials = await GoogleAuthProvider.credential(idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      print("hello ${_auth.signInWithCredential(crediantials)}");
      return await _auth.signInWithCredential(crediantials);
    }catch(e){
      print(e.toString());
    }
    return null;
  }
}