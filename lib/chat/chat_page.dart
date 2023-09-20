import 'dart:ui';
import 'package:chatify/chat/add_chat_page.dart';
import 'package:chatify/chat/chat_variables.dart';
import 'package:chatify/common/variables.dart';
import 'package:chatify/common/widgets.dart';
import 'package:chatify/profile/profile_screen.dart';
import 'package:chatify/profile/profile_variables.dart';
import 'package:flutter/material.dart';
import 'package:metaballs/metaballs.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.profileId});
  final String profileId;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String profileId;

  @override
  void initState() {
    super.initState();

    setState(() {
      profileId = widget.profileId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        const Metaballs(),
        Column(children: [
          Align(
            alignment: Alignment.topCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.transparent,
                  child: upperWidget())),
            )),
                const Spacer(),
                ClipRRect(
                  child: Align(alignment: Alignment.bottomCenter,
                  child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: Colors.transparent,
                  child: bottomWidget(),),),),
                )
        ],),   
      ]),
    );
  }

  Widget upperWidget() {
    return Container(
      
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 0.1, color: Colors.black))),
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth*0.01, screenHeight*0.05, 0, screenHeight*0.01),
            child: Row(
              children: [     
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddChat())),
              icon: Icon(Icons.arrow_back, size: backButtonSize,)),
              SizedBox(width: screenWidth*0.02,),
              ElevatedButton(
                clipBehavior: Clip.antiAlias,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.zero
                ),
                child: 
                  !usersProfilePics.containsKey(profileId) ? 
                        Image.asset('assets/default_profile_picture.jpg', fit: BoxFit.cover, height: screenHeight*0.08,
                        width: screenWidth*0.16,) : 
                        Image.file(usersProfilePics[profileId], fit: BoxFit.fill, height: screenHeight*0.08,
                        width: screenWidth*0.16,),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen(profileId: profileId))),
              ),
             
            ],),
          ),
        );
  }

  Widget bottomWidget() {
    return Row(                
                            children: [
                            SizedBox(
                              width: screenWidth,
                              height: screenHeight*0.1,
                              child: TextField(onChanged: (text) => setState(() {
                  if (checkEmptyText(text)) return;
                  currentMessage = text;
                              }),),
                            ),
                            
                          ],);
  }
}