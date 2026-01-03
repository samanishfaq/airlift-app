import 'package:airlift/app/ui/screens/caht/chatscreen.dart';
import 'package:airlift/app/ui/screens/call/callscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RideTrackingPage extends StatelessWidget {
  final Map<String, dynamic> driverData;
  final String rideId;

  const RideTrackingPage({
    super.key,
    required this.driverData,
    required this.rideId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ride Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Driver: ${driverData['username']}"),
            Text("Vehicle: ${driverData['vehicleNumber']}"),
            Text("Phone: ${driverData['phone']}"),

            const Divider(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => CallScreen(peerName: driverData['username']));
              },
              icon: const Icon(Icons.call),
              label: const Text("Call Driver"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => ChatScreen(
                  peerId: driverData['uid'],
                  peerName: driverData['username'],
                ));
              },
              icon: const Icon(Icons.chat),
              label: const Text("Chat with Driver"),
            ),
          ],
        ),
      ),
    );
  }
}
