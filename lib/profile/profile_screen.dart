import 'dart:io';

import 'package:chatify/chat/chat_page.dart';
import 'package:chatify/common/variables.dart';
import 'package:chatify/profile/profile.dart';
import 'package:chatify/profile/profile_variables.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profileId});
  final String profileId;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String profileId;
  final imgPicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    setState(() {
      profileId = widget.profileId;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await manageProfilePic(profileId, setStateCallback);
    });
  }

  void setStateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(screenHeight*0.03), child: IconButton(icon: Icon(Icons.arrow_back, size: backButtonSize,), 
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
                child: !usersProfilePics.containsKey(profileId) ? 
                Image.asset('assets/default_profile_picture.jpg', fit: BoxFit.fitWidth, height: screenHeight*0.4,
                width: screenWidth,) : 
                Image.file(usersProfilePics[profileId], fit: BoxFit.fill, height: screenHeight*0.4,
                width: screenWidth,),
                ),
                SizedBox(height: screenHeight*0.08,),
                Text(profileId, style: TextStyle(fontSize: screenWidth*0.1),),                
              ],
            ),
          ),
          profileId != currentUsername ? Expanded(
            child: Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth*0.71, screenHeight*0.21, 0, screenHeight*0.05),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(profileId: profileId,))),                  
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30)))),
                     child: const Icon(Icons.chat, size: 60, color: Colors.white,),),
                  ),
          ) : Container() 
        ],
      ),
    );
  }
}