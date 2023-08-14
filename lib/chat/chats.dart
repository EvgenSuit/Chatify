import 'package:chatify/auth/auth.dart';
import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';

final chatsRef = FirebaseDatabase.instance.ref('chats');
bool chatsExist = false;
bool chatsLoaded = false;
Future<void> checkForChats() async {
  final snapshot = await chatsRef.get();
  chatsLoaded = true;
  chatsExist = snapshot.exists;
}

final usersRef = FirebaseDatabase.instance.ref('users');
Future<bool> searchForUsername(String searchUsername) async {
  print(currentUsername);
  if (searchUsername == '' || searchUsername == currentUsername) return false;
  final snapshot = await usersRef.child(searchUsername).get();
  return snapshot.exists;
}

Future<void> addChat(String username) async {
  //usersRef.child(username).set(value);
}
