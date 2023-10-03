import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<bool> searchForUsername(String searchUsername) async {
  if (searchUsername == '' || searchUsername == currentUsername) return false;
  final snapshot = await usersRef.child(searchUsername).get();
  await Future.delayed(Duration(milliseconds: 900));
  return snapshot.exists;
}

final messagesRef = FirebaseDatabase.instance.ref('messages');
final chatsRef = FirebaseDatabase.instance.ref('chats');
final usersRef = FirebaseDatabase.instance.ref('users');
List<Chat> allChats = [];
Map allMessages = {};

class Chat extends ChangeNotifier {
  bool initialDataLoaded = false;
  String? chatId;
  String currentMessage = '';
  Map messages = {};
  Map newMessages = {};
  String receiver = '';
  String sender = '';
  String timeStamp = '';

  void getLastMessage() {}

  Future<void> addChat(String chatId) async {
    await chatsRef.child(chatId).set({
      'chatId': chatId,
    });
  }

  Future getChat(List<String> usernames) async {
    List userIds = [];
    for (String username in usernames) {
      usersRef.child(username).onValue.listen((event) {
        final data = event.snapshot.value as Map;
        userIds.add(data['userId']);
      });
    }
    await Future.doWhile(
      () async {
        await Future.delayed(Duration(milliseconds: 100));
        return userIds.isEmpty;
      },
    );
    chatId = userIds[0] > userIds[1]
        ? '${userIds[0]}${userIds[1]}'
        : '${userIds[1]}${userIds[0]}';
    await Future.doWhile(
      () async {
        return chatId == null;
      },
    );

    if (initialDataLoaded) {
      listenForValue(messagesRef, chatId!, false, true);
      notifyListeners();
    }

    listenForValue(messagesRef, chatId!, true, true);

    initialDataLoaded = true;
    notifyListeners();

    messagesRef.child(chatId!).onChildRemoved.listen((event) {
      messages = {};
      notifyListeners();
    });
  }

  listenForValue(
      DatabaseReference ref, String search, bool onValue, bool sortData) {
    final listener =
        onValue ? ref.child(search).onValue : ref.child(search).onChildAdded;
    listener.listen((event) {
      final snapshot = event.snapshot.value;

      if (snapshot == null)
        return;
      else {
        addChat(chatId!);
      }
      if (onValue) {
        messages = snapshot as Map;
      } else {
        messages.addAll(snapshot as Map);
      }
      if (sortData) {
        if (onValue) {
          messages = Map.fromEntries(messages.entries.toList()
            ..sort((e1, e2) {
              return e2.key.compareTo(e1.key);
            }));
        } else {
          messages.addAll(Map.fromEntries(messages.entries.toList()
            ..sort((e1, e2) {
              return e2.key.compareTo(e1.key);
            })));
        }
      }
      notifyListeners();
    });
  }

  Future<void> sendMessage(List<String> usernames, String message) async {
    final String messageId = DateTime.now().microsecondsSinceEpoch.toString();
    final messageToSend = {
      'sender': usernames[0],
      'receiver': usernames[1],
      'message': message,
      'timestamp': '${DateTime.now().hour}: ${DateTime.now().minute}',
    };
    await messagesRef.child(chatId!).child(messageId).set(messageToSend);
  }
}
