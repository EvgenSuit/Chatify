import 'dart:io';
import 'dart:ui';
import 'package:chatify/chat/chats.dart';
import 'package:chatify/common/variables.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'profile_variables.dart';

Future<void> uploadProfilePic(File img, String username) async {
  await userPicRef.child(username).putFile(img);
  final newProfilPicName = DateTime.now().millisecondsSinceEpoch;
  await prefs!.setInt('profilePicName', newProfilPicName);
  await usersInfoRef
      .child(username)
      .update({'profilePicName': newProfilPicName});
}

Future<void> manageProfilePic(String profileId, VoidCallback setState) async {
  Reference? currUserPicRef;
  int profilePicId = 0;
  if (internetIsOn) {
    currUserPicRef = userPicRef.child(profileId);
    final userData = (await usersInfoRef.child(profileId).get()).value as Map;
    // return if user's profile picture doesn't exist
    if ((await currUserPicRef.list()).items.isEmpty) return;
    profilePicId = userData['profilePicName'];
  } else {
    profilePicId = prefs!.getInt('profilePicName')!;
  }

  final filePath = "${externalStorageDir!.path}/imgs/profile/$profilePicId.jpg";
  final file = File(filePath);

  /*If profilePic with a specific Id doesn't exist 
      and then we'll download the picture from firestore
      (only if internet is on)
      */
  try {
    if (!file.existsSync() && internetIsOn) {
      await currUserPicRef!.writeToFile(file);
    }
    usersProfilePics[profileId] = file;
    setState();
  } on FirebaseException catch (e) {}
}
