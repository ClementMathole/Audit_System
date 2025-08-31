import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

  Future<Map<String, dynamic>?> getUserData() async {
    // Name: getUserData
    // Purpose: Retrieve user data from Firestore
    // Parameters: None
    // Returns: A map containing user data or null if not found
    var doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Stream<Map<String, dynamic>?> getUserDataStream() {
    // Name: getUserDataStream
    // Purpose: Stream user data from Firestore
    // Parameters: None
    // Returns: A stream of user data maps
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }
}
