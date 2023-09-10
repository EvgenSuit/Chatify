import 'package:chatify/common/variables.dart';
import 'package:chatify/profile/profile.dart';
import 'package:chatify/profile/variables.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profileId});
  final String profileId;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

//let the content of screen be changed if a user does it to their own profile
class _ProfileScreenState extends State<ProfileScreen> {



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
                    final tempImg = await FlutterNativeImage.compressImage(tempXfile.path);
                    setState(() {
                      currentUserProfilePic = tempImg;
                    });
                    await uploadProfilePic(currentUserProfilePic!);
                },
                clipBehavior: Clip.antiAlias,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.zero
                ),
                child: currentUserProfilePic == null ? Image.asset('assets/default-profile-picture1.jpg', fit: BoxFit.fitWidth, height: screenHeight*0.4,
                width: screenWidth,) : Image.file(currentUserProfilePic!, fit: BoxFit.fitWidth, height: screenHeight*0.4,
                width: screenWidth,),
                ),
                SizedBox(height: screenHeight*0.08,),
                Text(widget.profileId, style: TextStyle(fontSize: screenWidth*0.1),),                
              ],
            ),
          ),
          widget.profileId != currentUsername ? Padding(
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