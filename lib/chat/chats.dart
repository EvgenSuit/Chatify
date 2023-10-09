import 'dart:collection';
import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

final messagesRef = FirebaseDatabase.instance.ref('messages');
final chatsRef = FirebaseDatabase.instance.ref('chats');
final usersRef = FirebaseDatabase.instance.ref('users');
Chat chat = Chat();

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
    Map lastMessagesTemp = {};
    if (currentUserChats.isEmpty) {
      final usersSnapshot = await usersRef.get();
      final usersSnapshotMap = usersSnapshot.value as Map;
      if (usersSnapshotMap.isEmpty) return;
      final currentUserSnapshot = usersSnapshotMap[currentUsername!];
      if (!currentUserSnapshot.containsKey('chats')) return;
      for (String chatId in currentUserSnapshot['chats'].keys) {
        await getChat(chatId);
        final lastMessage = messages[chatId][messages[chatId].keys.last];
        currentUserChats = currentUserSnapshot['chats'];
        lastMessagesTemp[chatId] = lastMessage;
      }
      chat.lastMessages = lastMessagesTemp;
      notifyListeners();

      usersRef.onValue.listen((event) {
        chatsLoaded = true;
      });
    } else {
      usersRef.onChildAdded.listen((event) async {
        if (chatsLoaded) {
          for (String chatId in currentUserChats.keys) {
            final messageKey = messages[chatId].keys.last;
            lastMessages[chatId] = messages[chatId][messageKey];
            print(lastMessages);
          }
          notifyListeners();
        }
      });
    }
  }

  Future getChat(String chatId) async {
    if (!messages.containsKey(chatId)) {
      final snapshot = await messagesRef.child(chatId).get();
      final snapshotMap = snapshot.value as Map;
      if (snapshotMap.isNotEmpty) {
        messages[chatId] = SplayTreeMap.from(snapshotMap);
      }
      messagesRef.onChildAdded.listen((event) {
        messagesLoaded = true;
      });
    } else {
      messagesRef.child(chatId).onChildAdded.listen((event) {
        if (messagesLoaded) {
          final snapshot = event.snapshot.value as Map;
          if (snapshot.isEmpty) return;
          if (!messages.keys.contains(event.snapshot.key)) {
            messages[chatId].addAll({event.snapshot.key: snapshot});
          }
        }
      });
    }
  }

  Future<void> addChat() async {
    if (receiver == '') return;
    chatId = '${currentUsername}_$receiver';
    notifyListeners();

    await usersRef
        .child(currentUsername!)
        .child('chats')
        .child(chatId)
        .set(chatId);
    await usersRef.child(receiver).child('chats').child(chatId).set(chatId);
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
