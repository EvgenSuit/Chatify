import 'dart:collection';
import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

final messagesRef = FirebaseDatabase.instance.ref('messages');
final chatsRef = FirebaseDatabase.instance.ref('chats');
final usersRef = FirebaseDatabase.instance.ref('users');
Chat chat = Chat();
GetStorage box = GetStorage();

Future<bool> searchForUsername(String searchUsername) async {
  if (searchUsername == '' || searchUsername == currentUsername) return false;
  final snapshot = await usersRef.child(searchUsername).get();
  await Future.delayed(const Duration(milliseconds: 1200));
  return snapshot.exists;
}

class Chat extends ChangeNotifier {
  bool chatsLoaded = false;
  bool messagesLoaded = false;
  String chatId = '';
  String currentMessage = '';
  Map messages = {};
  String receiver = '';
  Map lastMessages = {};
  Map currentUserChats = {};

  getLastMessages() async {
    final readMessages = box.read('messages');
    messages = readMessages != null ? readMessages : messages;
    final usersSnapshot = await usersRef.get();
    final usersSnapshotMap = usersSnapshot.value as Map;
    if (usersSnapshotMap.isEmpty) return;
    final currentUserSnapshot = usersSnapshotMap[currentUsername!];
    if (!currentUserSnapshot.containsKey('chats')) return;
    currentUserChats = currentUserSnapshot['chats'];
    for (String chatId in currentUserSnapshot['chats'].keys) {
      await getChat(chatId);
    }

    box.write('messages', messages);
    usersRef.onValue.listen((event) {
      chatsLoaded = true;
    });

    usersRef
        .child(currentUsername!)
        .child('chats')
        .onChildAdded
        .listen((event) async {
      if (chatsLoaded) {
        await getChat(event.snapshot.value as String);
        box.write('messages', messages);
      }
    });
    notifyListeners();
  }

  Future getChat(String chatId) async {
    if (!messages.containsKey(chatId)) {
      final snapshot = await messagesRef.child(chatId).get();
      final snapshotMap = snapshot.value as Map;
      if (snapshotMap.isNotEmpty) {
        messages[chatId] = SplayTreeMap.from(snapshotMap);
      }
    }
    messages[chatId] = SplayTreeMap.from(messages[chatId]);
    currentUserChats.addAll({chatId: chatId});
    lastMessages[chatId] = messages[chatId][messages[chatId].keys.last];
    notifyListeners();

    messagesRef.child(chatId).onValue.listen((event) {
      messagesLoaded = true;
    });
    messagesRef.child(chatId).onChildAdded.listen((event) {
      if (messagesLoaded && messages.containsKey(chatId)) {
        final snapshot = event.snapshot.value as Map;
        if (snapshot.isEmpty) return;
        if (!messages.keys.contains(event.snapshot.key)) {
          currentUserChats.addAll({chatId: chatId});
          messages[chatId].addAll({event.snapshot.key: snapshot});
          lastMessages[chatId] = snapshot;
          lastMessages =
              Map.fromEntries(lastMessages.entries.toList().reversed);

          notifyListeners();
        }
      }
    });
  }

  Future<String> addChat(String receiver) async {
    final chatIdTemp = '${currentUsername}_$receiver';
    chatId = chatIdTemp;
    notifyListeners();

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
      'sender': usernames[0],
      'receiver': usernames[1],
      'message': message,
      'timestamp': '${DateTime.now()}',
    };
    await messagesRef.child(chatId).child(messageId).set(messageToSend);
  }
}
