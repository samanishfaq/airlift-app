import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Passengerdashboardcontroller extends GetxController {
  final RxInt currentIndex = 0.obs;
  final Rxn<Map<String, dynamic>> activeRide = Rxn<Map<String, dynamic>>();

  final String passengerId = 'passenger1';
  StreamSubscription<QuerySnapshot>? _rideSubscription;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _listenToActiveRide();
  }

  void _listenToActiveRide() {
    _rideSubscription?.cancel();

    _rideSubscription = FirebaseFirestore.instance
        .collection('rides')
        .where('passengerId', isEqualTo: passengerId)
        .limit(1)
        .snapshots()
        .listen(
      (snapshot) async {
        if (snapshot.docs.isEmpty) {
          activeRide.value = null;
          return;
        }

        final rideDoc = snapshot.docs.first;
        final status = rideDoc['status'];

        if (status != 'accepted') {
          activeRide.value = null;
          return;
        }

        final driverId = rideDoc['driverId'];
        if (driverId == null || driverId.isEmpty) {
          activeRide.value = null;
          return;
        }

        final driverDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .get();

        if (!driverDoc.exists) {
          activeRide.value = null;
          return;
        }

        activeRide.value = {
          'rideId': rideDoc.id,
          'driver': driverDoc.data(),
          'pickup': rideDoc['pickup'],
          'destination': rideDoc['destination'],
          'status': status,
        };
      },
      onError: (error) {
        /// 🔥 THIS PREVENTS DASHBOARD FREEZE
        print("Ride stream error: $error");
        activeRide.value = null;
      },
    );
  }

  @override
  void onClose() {
    _rideSubscription?.cancel();
    super.onClose();
  }
}
