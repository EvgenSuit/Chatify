import 'dart:collection';
import 'dart:ffi';

import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  bool initialDataLoaded = false;
  String? chatId;
  String currentMessage = '';
  Map messages = {};
  String receiver = '';
  String sender = '';
  String timeStamp = '';
  List lastMessages = [];

  Future getLastMessages() async {
    final currRef = usersRef.child(currentUsername!).child('chats');
    List lastMessagsesTemp = [];
    Future get(DatabaseEvent event) async {
      final children = event.snapshot.children.toList();
      for (DataSnapshot id in children) {
        chatId = id.value.toString();
        await getChat();

        if (chatId != null) {
          await Future.doWhile(() async {
            await Future.delayed(const Duration(milliseconds: 1));
            return messages.isEmpty;
          });
        }
        lastMessagsesTemp.add(messages[messages.keys.last]);
        lastMessages = lastMessagsesTemp;
        notifyListeners();
      }
    }

    currRef.onValue.listen((event) async {
      await get(event);
    });
    currRef.onChildAdded.listen((event) async {
      await get(event);
    });
    currRef.onChildRemoved.listen((event) async {
      await get(event);
    });
    currRef.onChildChanged.listen((event) async {
      await get(event);
    });
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 10));
      return lastMessages.isEmpty;
    });
  }

  Future<void> addChat() async {
    await usersRef
        .child(currentUsername!)
        .child('chats')
        .child(chatId!)
        .set(chatId!);
    await usersRef.child(receiver).child('chats').child(chatId!).set(chatId!);
    await chatsRef.child(chatId!).set({
      'chatId': chatId,
    });
  }

  Future getChat() async {
    if (chatId == null) {
      chatId = DateTime.now().microsecondsSinceEpoch.toString();
      await addChat();
    }

    if (initialDataLoaded) {
      listenForValue(messagesRef, chatId!, false, true);
      notifyListeners();
    }

    listenForValue(messagesRef, chatId!, true, true);
    notifyListeners();

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
        addChat();
      }
      if (onValue) {
        messages = snapshot as Map;
      } else {
        messages.addAll(snapshot as Map);
      }
      if (sortData) {
        if (onValue) {
          messages = SplayTreeMap.from(messages);
          //messages = Map.fromEntries(messages.entries.toList().sort((e1, e2)=>e1['timestamp'].compareTo(e2['timestamp'])));
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
      'timestamp': '${DateTime.now()}',
    };

    await messagesRef.child(chatId!).child(messageId).set(messageToSend);
  }
}
