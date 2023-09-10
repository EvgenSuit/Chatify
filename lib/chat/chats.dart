import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';

final chatsRef = FirebaseDatabase.instance.ref('chats');
final usersRef = FirebaseDatabase.instance.ref('users');
bool chatsExist = false;
bool chatsLoaded = false;
Future<void> checkForChats() async {
  final snapshot = await chatsRef.get();
  chatsLoaded = true;
  chatsExist = snapshot.exists;
  

  //if user has just signed up, use a default profile picture, if not, use the one a user set
}

Future<bool> searchForUsername(String searchUsername) async {
  
  if (searchUsername == '' || searchUsername == currentUsername) return false;
  final snapshot = await usersRef.child(searchUsername).get();
  return snapshot.exists;
}

Future<void> addChat(String username) async {
  //usersRef.child(username).set(value);
}
