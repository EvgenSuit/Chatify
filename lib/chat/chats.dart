import 'dart:collection';
import 'package:chatify/common/variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jiffy/jiffy.dart';

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
  Map messages = {};
  Map lastMessages = {};
  Map currentUserChats = {};
  Map usernameToIdMap = {};
  Map? readMessages = {};

  getLastMessages() {
    final readUserChats = box.read('chats/$currentUsername');
    currentUserChats = readUserChats ?? currentUserChats;
    currentUserChats = SplayTreeMap.from(currentUserChats);
    if (!disposed) notifyListeners();

    usersRef
        .child(currentUsername!)
        .child('chats')
        .onChildAdded
        .listen((event) async {
      final id = event.snapshot.value as String;
      currentUserChats[id] = id;
      if (!disposed) notifyListeners();
      final readMessages = box.read('messages');
      if (readMessages != null) {
        messages[id] = readMessages[id];

        if (!disposed) notifyListeners();
      }
      await getChat(id);
    });
  }

  Future getChat(String chatId) async {
    if (!messages.containsKey(chatId)) {
      final snapshot = await messagesRef.child(chatId).get();
      if (snapshot.value == null) return;
      final snapshotMap = snapshot.value as Map;
      if (snapshotMap.isNotEmpty) {
        messages[chatId] = SplayTreeMap.from(snapshotMap);
        messages[chatId] = convertFromUtc(messages[chatId]);
        if (!disposed) notifyListeners();
        await box.write('messages', messages);
      }
    }
    messages[chatId] = SplayTreeMap.from(messages[chatId]);
    currentUserChats[chatId] = chatId;
    lastMessages[chatId] = messages[chatId][messages[chatId].keys.last];
    if (!disposed) notifyListeners();
    messagesRef.child(chatId).onChildAdded.listen((event) async {
      if (!messages[chatId].keys.contains(event.snapshot.key)) {
        final snapshot = event.snapshot.value as Map;
        if (snapshot.isEmpty) return;
        currentUserChats[chatId] = chatId;
        messages[chatId].addAll(convertFromUtc({event.snapshot.key: snapshot}));
        lastMessages[chatId] = snapshot;
        lastMessages = Map.fromEntries(lastMessages.entries.toList().reversed);
        if (!disposed) notifyListeners();
        await box.write('messages', messages);
      }
    });
    if (!disposed) notifyListeners();
    messagesRef.child(chatId).onChildRemoved.listen((event) async {
      await removeMessage(chatId, int.parse(event.snapshot.key!), false);
    });
    //check if this works!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    messagesRef.child(chatId).onChildChanged.listen((event) async {});
  }

  Future<void> addChat(String receiver) async {
    if (currentUserChats.keys.contains(chatId)) return;
    final currentUserId =
        (await usersRef.child(currentUsername!).child('userId').get()).value;
    final receiverId =
        (await usersRef.child(receiver).child('userId').get()).value;
    if (!disposed) notifyListeners();
    final chatIdTemp = '${currentUserId}_$receiverId';

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
  }

  Future<void> sendMessage(List<String> usernames, String message) async {
    final currentTime = DateTime.now();

    final utcTime = Jiffy.now()
        .subtract(
            hours: currentTime.timeZoneOffset.inHours,
            minutes: currentTime.timeZoneOffset.inMinutes)
        .dateTime;

    final String messageId = currentTime.microsecondsSinceEpoch.toString();
    final messageToSend = {
      'id': messageId,
      'sender': usernames[0],
      'receiver': usernames[1],
      'message': message,
      'timestamp': '$utcTime',
    };
    messages[chatId][messageId] = messageToSend;
    if (!disposed) notifyListeners();
    await box.write("messages", messages);
    await messagesRef.child(chatId).child(messageId).set(messageToSend);
  }

  Future<void> removeMessage(
      String chatId, int messageIndex, bool fromSource) async {
    final messageId =
        messages[chatId].entries.toList()[messageIndex].value['id'];

    messages[chatId].remove(messageId);
    if (!disposed) notifyListeners();
    await box.write("messages", messages);

    if (fromSource) {
      await messagesRef.child(chatId).child(messageId).remove();
    }
  }

  Future<void> changeMessage(List<String> usernames, int messageIndex,
      String newContent, bool fromSource) async {
    final String messageId =
        messages[chatId].entries.toList()[messageIndex].value['id'];

    Map message = messages[chatId][messageId];
    message['message'] = newContent;
    if (!disposed) notifyListeners();
    await box.write("messages", messages);
    if (fromSource) {
      await messagesRef
          .child(chatId)
          .child(messageId)
          .update({'message': newContent});
    }
  }

  Map convertFromUtc(Map data) {
    data.forEach((key, val) {
      val['timestamp'] = Jiffy.parse(val['timestamp'])
          .add(
              hours: DateTime.now().timeZoneOffset.inHours,
              minutes: DateTime.now().timeZoneOffset.inMinutes)
          .dateTime
          .toString();
    });
    return data;
  }
}
