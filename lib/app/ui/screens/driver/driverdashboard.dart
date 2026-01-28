import 'package:airlift/app/controllers/driverdashboardcontroller.dart';
import 'package:airlift/app/ui/screens/driver/driverhome.dart';
import 'package:airlift/app/ui/screens/driver/driverprofile.dart';
import 'package:airlift/app/ui/screens/driver/riderequest.dart';
import 'package:airlift/commons/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverDashboard extends StatelessWidget {
  DriverDashboard({super.key});

  final DriverDashboardController controller =
      Get.put(DriverDashboardController(), permanent: true);

  final List<Widget> pages = const [
    Driverhome(),
    RideRequestsPage(),
    DriverProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          backgroundColor: AppColors.primaryBlue,
          selectedItemColor: AppColors.textWhite,
          unselectedItemColor: AppColors.bgDark,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}

