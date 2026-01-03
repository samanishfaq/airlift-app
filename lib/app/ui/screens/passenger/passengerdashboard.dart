import 'package:airlift/app/controllers/passengerdashboardcontroller.dart';
import 'package:airlift/app/ui/screens/passenger/passengerhome.dart';
import 'package:airlift/app/ui/screens/passenger/passengerprofile.dart';
import 'package:airlift/app/ui/screens/passenger/ridebooktrack.dart';
import 'package:airlift/app/ui/screens/passenger/ridehistory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Passengerdashboard extends StatelessWidget {
  Passengerdashboard({super.key});

  final Passengerdashboardcontroller controller =
      Get.put(Passengerdashboardcontroller());

  final pages = const [
    Passengerhome(),
    Ridehistory(),
    Passengerprofile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeRide = controller.activeRide.value;

      return Scaffold(
        body: activeRide != null
            ? RideTrackingPage(
                rideId: activeRide['rideId'],
                driverData: activeRide['driver'],
              )
            : pages[controller.currentIndex.value],
        bottomNavigationBar: activeRide == null
            ? BottomNavigationBar(
                currentIndex: controller.currentIndex.value,
                onTap: controller.changeTab,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.history), label: 'Rides'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profile'),
                ],
              )
            : null,
      );
    });
  }
}
