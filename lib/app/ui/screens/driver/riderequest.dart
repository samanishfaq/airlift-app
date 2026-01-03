import 'package:airlift/app/controllers/driverdashboardcontroller.dart';
import 'package:airlift/app/ui/shared/riderequestcard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RideRequestsPage extends StatelessWidget {
  const RideRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverDashboardController>();

    return Obx(() {
      if (controller.allRequests.isEmpty) {
        return const Center(child: Text("No ride requests"));
      }

      return ListView.builder(
        itemCount: controller.allRequests.length,
        itemBuilder: (_, i) {
          final ride = controller.allRequests[i];
          return RideRequestCard(
            request: ride,
            onAccept: () => controller.acceptRide(ride['id']),
            onReject: () => controller.rejectRide(ride['id']),
          );
        },
      );
    });
  }
}
