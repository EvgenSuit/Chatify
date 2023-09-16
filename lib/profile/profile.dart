import 'dart:io';
import 'package:chatify/common/variables.dart';
import 'profile_variables.dart';

Future<void> uploadProfilePic(File img, String username) async{
  await userPicRef.child(username).putFile(img);
  final newProfilPicName = DateTime.now().millisecondsSinceEpoch;
  await usersInfoRef.child(username).update({'profilePicName': newProfilPicName});
}