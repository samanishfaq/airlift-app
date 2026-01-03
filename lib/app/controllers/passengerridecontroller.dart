import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PassengerRideController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of rides for the current passenger
  Stream<QuerySnapshot<Map<String, dynamic>>> passengerRidesStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('rides')
        .where('passengerId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
