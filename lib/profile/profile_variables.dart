import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

Reference userPicRef = FirebaseStorage.instance.ref('profilePics/');
DatabaseReference usersInfoRef = FirebaseDatabase.instance.ref('users/');
File? currentUserProfilePic;
Map usersProfilePics = {};