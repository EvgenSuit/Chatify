import 'package:chatify/chat/chat_page.dart';
import 'package:chatify/chat/chats.dart';
import 'package:chatify/common/variables.dart';
import 'package:chatify/profile/profile.dart';
import 'package:chatify/profile/profile_variables.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profileId, required this.chat});
  final String profileId;
  final Chat chat;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String profileId;
  String? chatId;
  final imgPicker = ImagePicker();
  @override
  void initState() {
    super.initState();
    setState(() {
      profileId = widget.profileId;
    });

    if (!internetIsOn) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await manageProfilePic(profileId, setStateCallback);
    });
  }

  void setStateCallback() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgWidth = MediaQuery.of(context).orientation == Orientation.portrait
        ? screenWidth
        : screenWidth * 0.5;
    final imgHeight = MediaQuery.of(context).orientation == Orientation.portrait
        ? screenHeight * 0.4
        : screenHeight * 0.4;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.all(screenHeight * 0.03),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: backButtonSize,
                ),
                onPressed: () => Navigator.pop(context),
              )),
          Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (widget.profileId != currentUsername || !internetIsOn)
                      return;
                    final tempXfile = (await imgPicker.pickImage(
                        source: ImageSource.gallery));
                    if (tempXfile == null) return;
                    final profileImg = await FlutterNativeImage.compressImage(
                        tempXfile.path,
                        percentage: 50,
                        quality: 10);

                    setState(() {
                      usersProfilePics[profileId] = profileImg;
                    });
                    await uploadProfilePic(profileImg, profileId);
                  },
                  clipBehavior: Clip.antiAlias,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80)),
                      padding: EdgeInsets.zero),
                  child: !usersProfilePics.containsKey(profileId)
                      ? Image.asset(
                          'assets/default_profile_picture.jpg',
                          fit: BoxFit.fitWidth,
                          height: imgHeight,
                          width: imgWidth,
                        )
                      : Image.file(
                          usersProfilePics[profileId],
                          fit: BoxFit.fill,
                          height: imgHeight,
                          width: imgWidth,
                        ),
                ),
                SizedBox(
                  height: screenHeight * 0.08,
                ),
                Text(
                  profileId,
                  style: TextStyle(fontSize: screenWidth * 0.1),
                ),
              ],
            ),
          ),
          Spacer(),
          profileId != currentUsername
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    profileId: profileId,
                                    chat: widget.chat,
                                  )));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30)))),
                    child: Icon(
                      Icons.chat,
                      size: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth * 0.2
                          : screenWidth * 0.1,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
