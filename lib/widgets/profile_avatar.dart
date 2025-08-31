import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  final double radius;
  final Color backgroundColor;
  final TextStyle? textStyle;

  ProfileAvatar({
    // Name: ProfileAvatar
    // Purpose: Constructor for ProfileAvatar
    // Parameters:
    //   - Key? key: The widget key
    //   - double radius: The radius of the avatar
    //   - Color backgroundColor: The background color of the avatar
    //   - TextStyle? textStyle: The text style for initials
    super.key,
    this.radius = 20,
    this.backgroundColor = Colors.blue,
    this.textStyle,
  });

  String getInitials(String fullName) {
    // Name: getInitials
    // Purpose: Extract initials from the full name
    // Parameters:
    //   - String fullName: The full name of the user
    // Returns: A string containing the initials
    List<String> nameParts = fullName.trim().split(' ');
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();
    return nameParts.first[0].toUpperCase() + nameParts.last[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: Icon(
              CupertinoIcons.person,
              size: radius,
              color: Colors.grey,
            ),
          );
        }
        String fullName = snapshot.data!['name'] ?? '';
        String initials = getInitials(fullName);
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: Text(
            initials,
            style:
                textStyle ??
                TextStyle(
                  color: Colors.grey,
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.bold,
                ),
          ),
        );
      },
    );
  }
}
