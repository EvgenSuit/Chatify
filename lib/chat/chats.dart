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
    box.erase();
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

    final readMessages = box.read('messages');
    usersRef
        .child(currentUsername!)
        .child('chats')
        .onChildAdded
        .listen((event) async {
      if (readMessages == null ||
          !readMessages.keys.contains(event.snapshot.value)) {
        final id = event.snapshot.value as String;
        currentUserChats[id] = id;

        if (!disposed) notifyListeners();
        if (readMessages != null) {
          messages[id] = readMessages[id];
          if (!disposed) notifyListeners();
        }
        await getChat(id);
      }
    });
  }

  Future getChat(String chatId) async {
    if (!messages.containsKey(chatId) || messages[chatId] == null) {
      final snapshot = await messagesRef.child(chatId).get();
      if (snapshot.value != null) {
        final snapshotMap = snapshot.value as Map;
        if (snapshotMap.isNotEmpty) {
          messages[chatId] = SplayTreeMap.from(snapshotMap);
          messages[chatId] = convertFromUtc(messages[chatId]);
          currentUserChats[chatId] = chatId;
          lastMessages[chatId] = messages[chatId][messages[chatId].keys.last];
          notifyListeners();
          if (!disposed) notifyListeners();
          await box.write('messages/$chatId', {chatId: messages[chatId]});
        }
      }
    } else {
      messages = box.read('messages/$chatId');
      currentUserChats[chatId] = chatId;
      lastMessages[chatId] = messages[chatId][messages[chatId].keys.last];
      notifyListeners();
    }

    messagesRef.child(chatId).onChildAdded.listen((event) async {
      if (!messages.containsKey(chatId) || messages[chatId] == null) {
        messages[chatId] = {};
      }
      if (messages[chatId].keys.contains(event.snapshot.key)) return;
      final snapshot = event.snapshot.value as Map;
      if (snapshot.isEmpty) return;
      final newMessage = convertFromUtc({event.snapshot.key: snapshot});
      messages[chatId].addAll(newMessage);
      lastMessages[chatId] = newMessage.values.first;
      lastMessages = Map.fromEntries(lastMessages.entries.toList().reversed);
      await box.write('messages/$chatId', {chatId: messages[chatId]});
      notifyListeners();
    });

    messagesRef.child(chatId).onChildRemoved.listen((event) async {
      final id = event.snapshot.key!;
      await removeMessage(chatId, int.parse(id), false);
      if (messages[chatId].keys.isEmpty) {
        await deleteChat(chatId, (event.snapshot.value! as Map)['receiver']);
        messages.remove(chatId);
        lastMessages.remove(chatId);
        currentUserChats.remove(chatId);
        notifyListeners();
        await box.remove('messages/$chatId');

        await box.remove('chats/$currentUsername');
      }
    });
    messagesRef.child(chatId).onChildChanged.listen((event) async {
      Map changedMessage = {event.snapshot.key: event.snapshot.value};
      changedMessage = convertFromUtc(changedMessage);
      messages[chatId][event.snapshot.key] = changedMessage.values.first;
      lastMessages[chatId] = messages[chatId][messages[chatId].keys.last];
      notifyListeners();
      await box.write('messages/$chatId', {chatId: messages[chatId]});
    });
  }

  Future<void> addChat(String receiver) async {
    if (currentUserChats.keys.contains(chatId)) return;
    for (String key in currentUserChats.keys) {
      if (key.contains(receiver) && key.contains(currentUsername!)) return;
    }
    final currentUserId =
        (await usersRef.child(currentUsername!).child('userId').get())
            .value
            .toString();
    final receiverId =
        (await usersRef.child(receiver).child('userId').get()).value.toString();
    if (!disposed) notifyListeners();
    final chatIdTemp = '${currentUserId}_$receiverId';
    final userChats =
        await usersRef.child(currentUsername!).child('chats').get();
    if (userChats.value != null) {
      final userChatsMap = userChats.value as Map;
      for (String id in userChatsMap.keys) {
        if (id.contains(currentUserId) && id.contains(receiverId)) return;
      }
    }
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

  Future<void> deleteChat(String chatId, String receiver) async {
    await usersRef
        .child(currentUsername!)
        .child('chats')
        .child(chatId)
        .remove();
    await usersRef.child(receiver).child('chats').child(chatId).remove();
    //currentUserChats.remove(chatId);
  }

  Future<void> sendMessage(List<String> usernames, String message) async {
    final currentTime = Jiffy.now();

    final utcTime = currentTime
        .subtract(
            hours: currentTime.dateTime.timeZoneOffset.inHours,
            minutes: currentTime.dateTime.timeZoneOffset.inMinutes)
        .dateTime;
    final String messageId = currentTime.microsecondsSinceEpoch.toString();
    Map messageToSend = {
      'id': messageId,
      'sender': usernames[0],
      'receiver': usernames[1],
      'message': message,
      'timestamp': '$utcTime',
    };
    await messagesRef.child(chatId).child(messageId).set(messageToSend);
  }

  Future<void> removeMessage(
      String chatId, int messageIndex, bool fromSource) async {
    final String messageId = fromSource
        ? messages[chatId].entries.toList()[messageIndex].value['id']
        : messageIndex.toString();

    messages[chatId].remove(messageId);
    if (messages[chatId].isNotEmpty)
      lastMessages[chatId] = messages[chatId][messages[chatId].keys.last];
    notifyListeners();

    await box.write('messages/$chatId', {chatId: messages[chatId]});

    if (fromSource) {
      await messagesRef.child(chatId).child(messageId).remove();
    }
  }

  Future<void> changeMessage(List<String> usernames, int messageIndex,
      String newContent, bool fromSource) async {
    final String messageId =
        messages[chatId].entries.toList()[messageIndex].value['id'];

    /*Map message = messages[chatId][messageId];
    message['message'] = newContent;
    if (!disposed) notifyListeners();
    await box.write('messages/$chatId', {chatId: messages[chatId]}); */
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
