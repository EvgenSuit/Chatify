import 'package:firebase_database/firebase_database.dart';

final chatsRef = FirebaseDatabase.instance.ref('chats');
final usersRef = FirebaseDatabase.instance.ref('users');
final messagesRef = FirebaseDatabase.instance.ref('messages');
String currentMessage = '';