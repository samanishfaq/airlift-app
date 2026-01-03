import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:airlift/utils/text_field_decoration.dart';
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
  final String passengerId = 'passenger1';

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
      body: Stack(
        children: [
          CustomGoogleMap(
            destination: destination,
            showPolyline: destination != null,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                TextField(
                  controller: pickupCtrl,
                  decoration: inputDecoration(hintText: "Pickup location"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: destinationCtrl,
                  decoration: inputDecoration(hintText: "Destination"),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
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

    setState(() {
      destination = destinationLatLng;
    });

    try {
      await FirebaseFirestore.instance.collection('rides').add({
        'passengerId': passengerId,
        'passengerName': 'Passenger Demo',
        'passengerPhone': '03001234567',
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
        'status': 'pending',
        'driverId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Ride Requested",
        "Waiting for driver confirmation",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to request ride");
    } finally {
      setState(() => isBooking = false);
    }
  }
}
