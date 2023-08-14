import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatify/common/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isSignedIn = false;

void checkIfSignedIn(SharedPreferences prefs) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    isSignedIn = user != null;
    prefs.setBool('isSignedIn', isSignedIn);
  });
}

String email = '';
String password = '';
String username = '';

bool emptyCheck() {
  return username == '' || email == '' || password == '';
}

Future<void> auth({required String id}) async {
  if (emptyCheck()) {
    errorMessage = 'Some or all of the fields are empty';
    return;
  }
  await authUsername(id: id);
  if (errorMessage == 'Username already exists') {
    errorMessage = '';
    return;
  }
  try {
    if (id == 'Sign Up') {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } else {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    }
  } on FirebaseAuthException catch (e) {
    errorMessage = e.code;
    print(id);
    print(errorMessage);
  }
}

DatabaseReference ref = FirebaseDatabase.instance.ref('users/');
Future<void> authUsername({required String id}) async {
  final snapshot = await ref.child(username).get();
  if (id == 'Sign Up') {
    if (snapshot.exists) {
      print(snapshot);
      errorMessage = 'Username already exists';
    } else if (errorMessage == '') {
      await prefs!.setString('currentUsername', username);
      await ref.child(username).set({'username': username});
    }
  } else {
    if (snapshot.exists) {
      errorMessage = '';
      await prefs!.setString('currentUsername', username);
    } else {
      errorMessage = "Username doesn't exist";
    }
  }
}
