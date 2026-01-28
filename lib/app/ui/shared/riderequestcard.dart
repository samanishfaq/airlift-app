import 'package:flutter/material.dart';

class RideRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String pickup;
  final String destination;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onChat; // Optional chat callback
  final VoidCallback? onCall; // Optional call callback

  const RideRequestCard({
    super.key,
    required this.request,
    required this.pickup,
    required this.destination,
    required this.onAccept,
    required this.onReject,
    this.onChat,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final passengerName = request['passengerName'] ?? 'Passenger';
    final passengerPhone = request['passengerPhone'] ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup & Destination
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Expanded(child: Text("Pickup: $pickup")),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text("Destination: $destination")),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            // Passenger Info
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(child: Text(passengerName)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.phone, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(passengerPhone)),
              ],
            ),
            const SizedBox(height: 12),

            // Buttons: Accept / Reject / Chat / Call
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Accept"),
                ),
                ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Reject"),
                ),
                IconButton(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat, color: Colors.blue),
                ),
                IconButton(
                  onPressed: onCall,
                  icon: const Icon(Icons.call, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
