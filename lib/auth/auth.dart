import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chatify/common/variables.dart';

bool isSignedIn = false;

void checkIfSignedIn() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    isSignedIn = user != null;
    prefs!.setBool('isSignedIn', isSignedIn);
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
    return;
  }
  try {
    if (id == 'Sign Up') {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      errorMessage = '';
    } else {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      errorMessage = '';
    }
  } on FirebaseAuthException catch (e) {
    errorMessage = e.code;
    print(errorMessage);
  }
}

DatabaseReference ref = FirebaseDatabase.instance.ref('users/');
Future<void> authUsername({required String id}) async {
  final snapshot = await ref.child(username).get();
  if (id == 'Sign Up') {
    if (snapshot.exists) {
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
