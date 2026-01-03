import 'package:airlift/app/controllers/passengerridecontroller.dart';
import 'package:airlift/commons/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Ridehistory extends StatelessWidget {
  const Ridehistory({super.key});

  @override
  Widget build(BuildContext context) {
    final PassengerRideController controller =
        Get.put(PassengerRideController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: StreamBuilder(
        stream: controller.passengerRidesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = snapshot.data!.docs;

          if (rides.isEmpty) {
            return const Center(child: Text("No rides found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ride = rides[index].data() as Map<String, dynamic>;

              final pickup = ride['pickup']?['name'] ?? '';
              final destination = ride['destination']?['name'] ?? '';
              final status = ride['status'] ?? 'pending';

              return _buildRideCard(
                date: ride['createdAt']?.toDate().toString().substring(0, 16) ??
                    '',
                pickup: pickup,
                destination: destination,
                status: status,
              );
            },
          );
        },
      ),
    );
  }

  // ------------------ CARD ------------------

  Widget _buildRideCard({
    required String date,
    required String pickup,
    required String destination,
    required String status,
  }) {
    final color = statusColor(status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DATE + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(color: AppColors.bgLight),
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
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // PICKUP
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Expanded(child: Text(pickup)),
              ],
            ),

            const SizedBox(height: 8),

            // DESTINATION
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(destination)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ STATUS COLOR ------------------

  Color statusColor(String status) {
    if (status == 'accepted') return AppColors.successGreen;
    if (status == 'pending') return Colors.orange;
    return AppColors.alertRed;
  }
}
