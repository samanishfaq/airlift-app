import 'package:airlift/app/controllers/driverdashboardcontroller.dart';
import 'package:airlift/app/ui/shared/custom_google_map.dart';
import 'package:airlift/app/ui/shared/riderequestcard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Driverhome extends StatelessWidget {
  const Driverhome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverDashboardController>();

    return Stack(
      children: [
        const CustomGoogleMap(),
        Obx(() {
          final request = controller.currentRequest.value;
          if (request == null) return const SizedBox();

          return Positioned(
            bottom: 90,
            left: 16,
            right: 16,
            child: RideRequestCard(
              request: request,
              onAccept: () => controller.acceptRide(request['id']),
              onReject: () => controller.rejectRide(request['id']),
            ),
          );
        }),
      ],
    );
  }
}
