import 'package:airlift/app/controllers/driverdashboardcontroller.dart';
import 'package:airlift/app/ui/shared/custom_google_map.dart';
import 'package:airlift/app/ui/shared/riderequestcard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

          // Only show chat & call if ride is accepted
          final isAccepted = request['status'] == 'accepted';

          return Positioned(
            bottom: 90,
            left: 16,
            right: 16,
            child: RideRequestCard(
              request: request,
              pickup: request['pickup']?['name'] ?? '',
              destination: request['destination']?['name'] ?? '',
              onAccept: () => controller.acceptRide(request['id']),
              onReject: () => controller.rejectRide(request['id']),
              onChat: isAccepted
                  ? () {
                      // Open chat page
                      Get.toNamed('/chat', arguments: {
                        'rideId': request['id'],
                        'passengerId': request['passengerId']
                      });
                    }
                  : null,
              onCall: isAccepted
                  ? () async {
                      final phone = request['passengerPhone'];
                      if (phone != null && phone.isNotEmpty) {
                        final url = 'tel:$phone';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      }
                    }
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
