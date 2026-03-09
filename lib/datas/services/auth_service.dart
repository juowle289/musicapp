// // lib/data/services/auth_service.dart
// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<User?> signUp(String email, String password) async {
//     final credential = await _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     return credential.user;
//   }

//   Future<User?> signIn(String email, String password) async {
//     final credential = await _auth.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     return credential.user;
//   }
// }