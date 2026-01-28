import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DriverDashboardController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final Rxn<Map<String, dynamic>> currentRequest = Rxn();
  final RxList<Map<String, dynamic>> allRequests = <Map<String, dynamic>>[].obs;

  String? driverId;
  String? driverName;
  String? driverPhone;

  /// Reactive approval status
  RxBool isApproved = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      driverId = user.uid;
      _loadDriverInfo();
      _listenApprovalStatus();
      _listenRideRequests();
    }
  }

  /// 🔁 Bottom navigation
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// 🔥 Load driver name & phone from Firestore
  Future<void> _loadDriverInfo() async {
    if (driverId == null) return;

    final doc = await _firestore.collection('users').doc(driverId).get();
    if (doc.exists) {
      final data = doc.data();
      driverName = data?['username'] ?? '';
      driverPhone = data?['phone'] ?? '';
    }
  }

  /// 🔥 Listen admin approval status in real time
  void _listenApprovalStatus() {
    if (driverId == null) return;

    _firestore.collection('users').doc(driverId).snapshots().listen((doc) {
      if (doc.exists) {
        isApproved.value = doc.data()?['approved'] ?? false;
      }
    });
  }

  /// 🔥 Listen to passenger ride requests
  void _listenRideRequests() {
    _firestore
        .collection('rides')
        .where('status', isEqualTo: 'requested')
        .where('driverId', isNull: true)
        .snapshots()
        .listen((snapshot) {
      final rides =
          snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();

      allRequests.assignAll(rides);
      currentRequest.value = rides.isNotEmpty ? rides.first : null;
    });
  }

  /// ✅ Accept ride
  Future<void> acceptRide(String rideId) async {
    if (driverId == null) return;

    await _firestore.collection('rides').doc(rideId).update({
      'status': 'accepted',
      'driverId': driverId,
      'driverName': driverName ?? '',
      'driverPhone': driverPhone ?? '',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ❌ Reject ride
  Future<void> rejectRide(String rideId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}
