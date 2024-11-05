import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          //credentials
          email: email,
          password: password);

      return cred.user;
    } catch (e) {
      print("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          //credentials
          email: email,
          password: password);

      return cred.user;
    } catch (e) {
      print("Something went wrong");
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Something went wrong");
    }
  }
}