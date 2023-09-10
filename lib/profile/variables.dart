import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

File? currentUserProfilePic;
final userPicRef = FirebaseStorage.instance.ref('profilePics/');

