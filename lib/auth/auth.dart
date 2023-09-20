import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chatify/common/variables.dart';
import 'package:path_provider/path_provider.dart';

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
  await checkUsername(id: id);
  if (errorMessage.isNotEmpty) {
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
  } on FirebaseException catch (e) {
    errorMessage = e.code;
  }
  
  if (errorMessage.isNotEmpty) return;
  final currentUserRef = ref.child(username);
  if ((await currentUserRef.once()).snapshot.exists) return;
  await authUsername();
  await createDirs();
}

DatabaseReference ref = FirebaseDatabase.instance.ref('users/');
Future<void> checkUsername({required String id}) async {
  final snapshot = await ref.child(username).get();
  if (id == 'Sign Up') {
    if (snapshot.exists) {
      errorMessage = 'Username already exists';
    }
  } else {
    if (snapshot.exists) {
      errorMessage = ''; 
    } 
    else{
      errorMessage = "Username doesn't exist";
      return;
    }

    if((snapshot.value as Map)['email'] != email) {
      errorMessage = 'Wrong email';
    }
  }
}

Future<void> authUsername() async{
  final profilePicId = DateTime.now().millisecondsSinceEpoch;
  await ref.child(username).set({'username': username, 'email': email, 'last_seen': 0, 'profilePicName':profilePicId});
  await prefs!.setString('currentUsername', username);
}

Future<void> createDirs() async{
  final dirsToCreate = ['/imgs/profile/currentUser'];
  final storageDir = (await getExternalStorageDirectory())!.path;

  for (String dir in dirsToCreate) {
    final subDirs = dir.split('/');
    String start = storageDir;
    for (String subDir in subDirs) {
      start += '$subDir/';
      await Directory(start).create();
    
  }
}
}
