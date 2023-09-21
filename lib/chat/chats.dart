import 'package:chatify/chat/chat_variables.dart';
import 'package:chatify/common/variables.dart';

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

Future<void> addChat(List<String> usernames, String chatId, String chatIdKey) async {
  await chatsRef.child(chatId).set(usernames);
  await prefs!.setString(chatIdKey, chatId);
}

Future<void> sendMessage(List<String> usernames, String message) async{
  List allChats = [];
  for (var i in (await chatsRef.get()).children) {
    final values = i.value as List;
    allChats.add([i.key, values[0], values[1]]);
  }
  final currChat = allChats.where((element) => 
  (element.contains(usernames[0]) || element.contains(usernames[1]))).toList()[0];
  String? chatId;
  final String chatIdKey = '[${usernames[0]}, ${usernames[1]}]';
  chatId = prefs!.getString(chatIdKey);
  
  if (chatId == null || currChat.isEmpty) {
    chatId = DateTime.now().microsecondsSinceEpoch.toString();
    await addChat(usernames, chatId, chatIdKey);
  }
  else {
    chatId = currChat[0];
  }
  final String messageId = DateTime.now().microsecondsSinceEpoch.toString();
  await messagesRef.child(chatId!).child(messageId).set({
    'sender': usernames[0],
    'message': message,
    'timestemp': '${DateTime.now().hour}: ${DateTime.now().minute}'
  });
}

Future<void> getMessages(String chatId) async{
  final messages = messagesRef.child(chatId);
}