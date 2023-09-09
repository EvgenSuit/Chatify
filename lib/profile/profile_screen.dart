import 'package:chatify/auth/auth.dart';
import 'package:chatify/common/variables.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

//let the content of screen be changed if a user does it to their own profile
class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(screenHeight*0.02), child: IconButton(icon: Icon(Icons.arrow_back), 
        onPressed: () => Navigator.pop(context),)),
          Center(
            child: Column(
              children: [
                Container(width: screenWidth*0.4, height: screenHeight*0.4,
                decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/default-profile-picture1.jpg'))),),
                  Text(currentUsername!, style: TextStyle(fontSize: screenWidth*0.1),),
              ],
            ),
          )
          
        ],
      ),
    );
  }
}