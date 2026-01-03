import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DriverDashboardController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final Rxn<Map<String, dynamic>> currentRequest = Rxn();
  final RxList<Map<String, dynamic>> allRequests = <Map<String, dynamic>>[].obs;

  final String driverId = 'driver1'; // later from auth

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _listenPendingRides();
  }

  void _listenPendingRides() {
    FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      allRequests.clear();

      for (var doc in snapshot.docs) {
        allRequests.add({...doc.data(), 'id': doc.id});
      }

      currentRequest.value =
          allRequests.isNotEmpty ? allRequests.first : null;
    });
  }

  Future<void> acceptRide(String rideId) async {
    await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
      'status': 'accepted',
      'driverId': driverId,
    });
  }

  Future<void> rejectRide(String rideId) async {
    await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
      'status': 'rejected',
    });
  }
}
