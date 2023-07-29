import 'package:firebase_database/firebase_database.dart';

final ref = FirebaseDatabase.instance.ref('chats');
bool chatsExist = false;
bool chatsLoaded = false;
Future<void> checkForChats() async {
  final snapshot = await ref.get();
  chatsLoaded = true;
  chatsExist = snapshot.exists;
  print(snapshot.exists);
}
