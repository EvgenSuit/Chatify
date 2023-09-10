import 'dart:io';
import 'package:chatify/common/variables.dart';
import 'variables.dart';

Future<void> uploadProfilePic(File img) async{
  await userPicRef.child(currentUsername!).putFile(img);
}