import 'package:airlift/app/controllers/passengerridecontroller.dart';
import 'package:airlift/commons/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Ridehistory extends StatefulWidget {
  const Ridehistory({super.key});

  @override
  State<Ridehistory> createState() => _RidehistoryState();
}

class _RidehistoryState extends State<Ridehistory> {
  final PassengerRideController controller =
      Get.put(PassengerRideController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.passengerRidesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final rides = snapshot.data?.docs ?? [];

          if (rides.isEmpty) {
            return const Center(child: Text("No rides found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ride = rides[index].data();

              // Safe timestamp handling
              DateTime rideTime;
              final ts = ride['createdAt'];
              if (ts is Timestamp) {
                rideTime = ts.toDate();
              } else if (ts is DateTime) {
                rideTime = ts;
              } else {
                rideTime = DateTime.now();
              }

              final pickupName = ride['pickup']?['name'] ?? 'N/A';
              final destinationName = ride['destination']?['name'] ?? 'N/A';
              final status = ride['status'] ?? 'requested';
              final driverName = ride['driverName'] ?? '';
              final driverPhone = ride['driverPhone'] ?? '';

              return _buildRideCard(
                date:
                    "${rideTime.day}/${rideTime.month}/${rideTime.year} ${rideTime.hour}:${rideTime.minute.toString().padLeft(2, '0')}",
                pickup: pickupName,
                destination: destinationName,
                status: status,
                driverName: driverName,
                driverPhone: driverPhone,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRideCard({
    required String date,
    required String pickup,
    required String destination,
    required String status,
    String? driverName,
    String? driverPhone,
  }) {
    final color = statusColor(status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(color: AppColors.bgLight, fontSize: 12),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pickup
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pickup,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Destination
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destination,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            // Driver info and contact buttons (only if accepted)
            if (status.toLowerCase() == 'accepted') ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.bgLight.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                "Driver: ${driverName ?? 'N/A'}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Phone: ${driverPhone ?? 'N/A'}",
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text("Call"),
                      onPressed: () {
                        if (driverPhone != null && driverPhone.isNotEmpty) {
                          launchUrl(Uri.parse("tel:$driverPhone"));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text("Chat"),
                      onPressed: () {
                        // Navigate to chat screen with driver
                        if (driverPhone != null && driverPhone.isNotEmpty) {
                          Get.toNamed('/chat', arguments: {
                            'driverId': driverPhone,
                            'driverName': driverName,
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.successGreen;
      case 'requested':
        return Colors.orange;
      case 'rejected':
        return AppColors.alertRed;
      default:
        return Colors.grey;
    }
  }
}
