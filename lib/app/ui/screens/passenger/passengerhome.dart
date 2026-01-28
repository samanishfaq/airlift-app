import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:airlift/utils/text_field_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/custom_google_map.dart';

class Passengerhome extends StatefulWidget {
  const Passengerhome({super.key});

  @override
  State<Passengerhome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<Passengerhome> {
  final pickupCtrl = TextEditingController();
  final destinationCtrl = TextEditingController();

  LatLng? destination;
  bool isBooking = false;

  @override
  void dispose() {
    pickupCtrl.dispose();
    destinationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          /// 🗺 MAP (TOP SECTION)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: CustomGoogleMap(
              destination: destination,
              showPolyline: destination != null,
            ),
          ),

          /// 🧾 FORM (BOTTOM SECTION)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(color: AppColors.textWhite),
                    controller: pickupCtrl,
                    decoration: inputDecoration(hintText: "Pickup location"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(color: AppColors.textWhite),
                    controller: destinationCtrl,
                    decoration: inputDecoration(hintText: "Destination"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBooking ? null : _bookRide,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isBooking
                          ? CircularProgressIndicator(
                              color: AppColors.textWhite,
                            )
                          : const AppText(
                              text: "Book Now",
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bookRide() async {
    if (pickupCtrl.text.isEmpty || destinationCtrl.text.isEmpty) {
      Get.snackbar("Error", "Please enter pickup and destination");
      return;
    }

    setState(() => isBooking = true);

    final pickupLatLng = const LatLng(28.4326, 70.2990);
    final destinationLatLng = const LatLng(28.4526, 70.2990);

    setState(() => destination = destinationLatLng);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      // Get passenger info from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final passengerName = doc.data()?['username'] ?? 'Passenger';
      final passengerPhone = doc.data()?['phone'] ?? '';

      // Add ride to Firestore with passenger info
      await FirebaseFirestore.instance.collection('rides').add({
        'passengerId': user.uid,
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'pickup': {
          'lat': pickupLatLng.latitude,
          'lng': pickupLatLng.longitude,
          'name': pickupCtrl.text,
        },
        'destination': {
          'lat': destinationLatLng.latitude,
          'lng': destinationLatLng.longitude,
          'name': destinationCtrl.text,
        },
        'status': 'requested',
        'driverId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Ride Requested",
        "Waiting for driver confirmation",
        snackPosition: SnackPosition.BOTTOM,
      );

      pickupCtrl.clear();
      destinationCtrl.clear();
      setState(() => destination = null);
    } catch (e) {
      Get.snackbar("Error", "Failed to request ride");
    } finally {
      setState(() => isBooking = false);
    }
  }
}
