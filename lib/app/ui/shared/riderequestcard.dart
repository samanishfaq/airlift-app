import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RideRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RideRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final passengerName = request['passengerName'] ?? 'Passenger';
    final passengerPhone = request['passengerPhone'];
    final pickup = request['pickup'];
    final destination = request['destination'];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Passenger Info
            Row(
              children: [
                const Icon(Icons.person, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    passengerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (passengerPhone != null)
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () async {
                      final uri = Uri.parse("tel:$passengerPhone");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 8),

            /// Pickup & Destination
            Text(
              "Pickup: ${pickup?['lat']}, ${pickup?['lng']}",
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              "Drop: ${destination?['lat']}, ${destination?['lng']}",
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 12),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Accept",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Reject",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
