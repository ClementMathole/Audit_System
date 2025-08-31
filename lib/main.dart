import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skills_audit_system/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  // Name: main
  // Purpose: Entry point of the application
  // Parameters: None
  // Returns: None
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode("en");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SkillsAuditSystem());
}

class SkillsAuditSystem extends StatelessWidget {
  const SkillsAuditSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skills Audit System',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: Wrapper(),
    );
  }
}
