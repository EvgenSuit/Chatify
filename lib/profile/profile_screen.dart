import 'dart:io';

import 'package:chatify/common/variables.dart';
import 'package:chatify/profile/profile.dart';
import 'package:chatify/profile/profile_variables.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profileId});
  final String profileId;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String profileId;
  int profilePicId = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      profileId = widget.profileId;
      
    });
    final currUserPicRef = userPicRef.child(profileId);
    usersInfoRef.child(profileId).get().then((value) {
      final userData = value.value as Map;
      setState(() {
        profilePicId = userData['profilePicName'];
      });      
    
      final filePath = "${externalStorageDir!.path}/imgs/profile/$profilePicId.jpg";
      final file = File(filePath);
      setState(() {
        usersProfilePics[profileId] = file;
      });
      /*If profilePic with a specific Id doesn't exist
      and if usersProfilePics contains the current profile id
      (e.g when a user has just uploaded a picture), then we'll download the picture
      from firestore, otherwise it simply doesn't exist
      */
      
      if (!file.existsSync() && usersProfilePics.containsKey(profileId)) {
      currUserPicRef.writeToFile(file).then((p0) {
        setState(() {
        usersProfilePics[profileId] = file;
      });
      }); 
      }
    });
  }

  final imgPicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(screenHeight*0.02), child: IconButton(icon: const Icon(Icons.arrow_back), 
        onPressed: () => Navigator.pop(context),)),
          Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: ()async {
                    if (widget.profileId != currentUsername) return;
                    final tempXfile = (await imgPicker.pickImage(source: ImageSource.gallery));
                    if (tempXfile == null) return;
                    final profileImg = await FlutterNativeImage.compressImage(tempXfile.path,
                    percentage: 50,
                    quality: 10);   
                                 
                    setState(() {
                      usersProfilePics[profileId] = profileImg;
                    });                 
                    await uploadProfilePic(profileImg, profileId);                                        
                },
                clipBehavior: Clip.antiAlias,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.zero
                ),
                child: !usersProfilePics.containsKey(profileId) ? Image.asset('assets/default_profile_picture.jpg', fit: BoxFit.fitWidth, height: screenHeight*0.4,
                width: screenWidth,) : Image.file(usersProfilePics[profileId], fit: BoxFit.fill, height: screenHeight*0.4,
                width: screenWidth,),
                ),
                SizedBox(height: screenHeight*0.08,),
                Text(profileId, style: TextStyle(fontSize: screenWidth*0.1),),                
              ],
            ),
          ),
          profileId != currentUsername ? Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth*0.7, screenHeight*0.2, 0, screenHeight*0.05),
                  child: ElevatedButton(
                    onPressed: () {},                  
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))),
                   child: const Icon(Icons.chat, size: 50, color: Colors.white,),),
                ) : Container() 
        ],
      ),
    );
  }
}