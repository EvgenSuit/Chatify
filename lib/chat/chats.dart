import 'dart:collection';
import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

final messagesRef = FirebaseDatabase.instance.ref('messages');
final chatsRef = FirebaseDatabase.instance.ref('chats');
final usersRef = FirebaseDatabase.instance.ref('users');
GetStorage box = GetStorage();
bool messagesReceived = false;

Future<bool> searchForUsername(String searchUsername) async {
  if (searchUsername == '' || searchUsername == currentUsername) return false;
  final snapshot = await usersRef.child(searchUsername).get();
  await Future.delayed(const Duration(milliseconds: 1200));
  return snapshot.exists;
}

class Chat extends ChangeNotifier {
  bool disposed = false;
  Chat() {
    if (!disposed) getLastMessages();
  }

  @override
  void dispose() {
    disposed = true;
  }

  bool chatsLoaded = false;
  bool messagesLoaded = false;
  String chatId = '';
  String currentMessage = '';
  Map messages = {};
  String receiver = '';
  Map lastMessages = {};
  Map currentUserChats = {};
  Map? readMessages = {};

  getLastMessages() {
    final readUserChats = box.read('chats/$currentUsername');

    currentUserChats = readUserChats ?? currentUserChats;
    currentUserChats = SplayTreeMap.from(currentUserChats);

    usersRef
        .child(currentUsername!)
        .child('chats')
        .onChildAdded
        .listen((event) async {
      final id = event.snapshot.value;
      currentUserChats[id] = id as String;
      if (!disposed) notifyListeners();
      final readMessages = box.read('messages/$id');
      if (readMessages != null) {
        messages[id] = readMessages[id];
        if (!disposed) notifyListeners();
      }
      if (messages.isNotEmpty) await getChat(id);
    });
  }

  Future getChat(String chatId) async {
    if (!messages.containsKey(chatId)) {
      final snapshot = await messagesRef.child(chatId).get();
      final snapshotMap = snapshot.value as Map;
      if (snapshotMap.isNotEmpty) {
        messages[chatId] = SplayTreeMap.from(snapshotMap);
        await box.write('messages/$chatId', messages);
      }
    }
    messages[chatId] = SplayTreeMap.from(messages[chatId]);
    currentUserChats[chatId] = chatId;
    lastMessages[chatId] = messages[chatId][messages[chatId].keys.last];
    if (!disposed) notifyListeners();
    messagesRef.child(chatId).onChildAdded.listen((event) {
      if (!messages[chatId].keys.contains(event.snapshot.key)) {
        final snapshot = event.snapshot.value as Map;
        if (snapshot.isEmpty) return;
        currentUserChats[chatId] = chatId;
        messages[chatId].addAll({event.snapshot.key: snapshot});
        lastMessages[chatId] = snapshot;
        lastMessages = Map.fromEntries(lastMessages.entries.toList().reversed);
        if (!disposed) notifyListeners();
        box.write('messages/$chatId', messages);
      }
    });
  }

  Future<String> addChat(String receiver) async {
    final chatIdTemp = '${currentUsername}_$receiver';

    chatId = chatIdTemp;
    if (!disposed) notifyListeners();

    await usersRef
        .child(currentUsername!)
        .child('chats')
        .child(chatIdTemp)
        .set(chatIdTemp);
    await usersRef
        .child(receiver)
        .child('chats')
        .child(chatIdTemp)
        .set(chatIdTemp);
    return chatIdTemp;
  }

  Future<void> sendMessage(
      List<String> usernames, String message, String chatId) async {
    final String messageId = DateTime.now().microsecondsSinceEpoch.toString();
    final messageToSend = {
      'id': messageId,
      'sender': usernames[0],
      'receiver': usernames[1],
      'message': message,
      'timestamp': '${DateTime.now()}',
    };
    await messagesRef.child(chatId).child(messageId).set(messageToSend);
  }
}
