import 'package:airlift/app/controllers/driverdashboardcontroller.dart';
import 'package:airlift/app/ui/shared/riderequestcard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RideRequestsPage extends StatelessWidget {
  const RideRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverDashboardController>();

    return Obx(() {
      // Pending approval
      if (!controller.isApproved.value) {
        return const Center(
          child: Text(
            "Your account is pending admin approval",
            style: TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        );
      }

      if (controller.allRequests.isEmpty) {
        return const Center(child: Text("No ride requests"));
      }

      return ListView.builder(
        itemCount: controller.allRequests.length,
        itemBuilder: (_, i) {
          final ride = controller.allRequests[i];
          final isAccepted = ride['status'] == 'accepted';

          return RideRequestCard(
            request: ride,
            pickup: ride['pickup']?['name'] ?? '',
            destination: ride['destination']?['name'] ?? '',
            onAccept: () => controller.acceptRide(ride['id']),
            onReject: () => controller.rejectRide(ride['id']),
            onChat: isAccepted
                ? () {
                    Get.toNamed('/chat', arguments: {
                      'rideId': ride['id'],
                      'passengerId': ride['passengerId']
                    });
                  }
                : null,
            onCall: isAccepted
                ? () async {
                    final phone = ride['passengerPhone'];
                    if (phone != null && phone.isNotEmpty) {
                      final url = 'tel:$phone';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    }
                  }
                : null,
          );
        },
      );
    });
  }
}
