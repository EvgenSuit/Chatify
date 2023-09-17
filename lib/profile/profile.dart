import 'dart:io';
import 'dart:ui';
import 'package:chatify/common/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_variables.dart';

Future<void> uploadProfilePic(File img, String username) async{
  await userPicRef.child(username).putFile(img);
  final newProfilPicName = DateTime.now().millisecondsSinceEpoch;
  await usersInfoRef.child(username).update({'profilePicName': newProfilPicName});
}

Future<void> manageProfilePic(String profileId, VoidCallback setState) async{
    final currUserPicRef = userPicRef.child(profileId);
    final userData = (await usersInfoRef.child(profileId).get()).value as Map;
      final profilePicId = userData['profilePicName'];     

      final filePath = "${externalStorageDir!.path}/imgs/profile/$profilePicId.jpg";
      final file = File(filePath);
      /*If profilePic with a specific Id doesn't exist 
      and then we'll download the picture from firestore
      */
      
      try {
        if (!file.existsSync()) {
        await currUserPicRef.writeToFile(file);
        
      }
      usersProfilePics[profileId] = file;
      setState();
      }
      on FirebaseException catch (e){} 
}