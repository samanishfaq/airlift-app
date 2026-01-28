import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final String usersCollection = 'users';
  final String ridesCollection = 'rides';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: "AdminDashbord",
          color: AppColors.textWhite,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: AppColors.bgDark,
          indicatorColor: Colors.deepOrange,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.textWhite,
          indicatorWeight: 2.0,
          tabs: const [
            Tab(text: "Drivers"),
            Tab(text: "Rides"),
            Tab(text: "Statistics"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _driversTab(),
          _ridesTab(),
          _statisticsTab(),
        ],
      ),
    );
  }

  /// 👨‍✈️ Drivers Tab
  Widget _driversTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(usersCollection)
          .where('role', isEqualTo: 'driver')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final drivers = snapshot.data?.docs ?? [];
        if (drivers.isEmpty) {
          return const Center(child: Text("No drivers found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final driver = drivers[index].data() as Map<String, dynamic>;
            final driverId = drivers[index].id;
            final isApproved = driver['approved'] ?? false;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(driver['username'] ?? 'N/A'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phone: ${driver['phone'] ?? 'N/A'}"),
                    Text("Vehicle: ${driver['vehicleType'] ?? 'N/A'}"),
                    Text("Vehicle No: ${driver['vehicleNumber'] ?? 'N/A'}"),
                    Text(
                      "Status: ${isApproved ? 'Approved' : 'Pending'}",
                      style: TextStyle(
                        color: isApproved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: isApproved
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection(usersCollection)
                              .doc(driverId)
                              .update({'approved': false});
                          Get.snackbar("Driver Updated",
                              "${driver['username']} set to Pending",
                              snackPosition: SnackPosition.BOTTOM);
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection(usersCollection)
                              .doc(driverId)
                              .update({'approved': true});
                          Get.snackbar("Driver Approved",
                              "${driver['username']} is now approved",
                              snackPosition: SnackPosition.BOTTOM);
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🚗 Rides Tab
  Widget _ridesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(ridesCollection).snapshots(),
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index].data() as Map<String, dynamic>;
            final rideId = rides[index].id;
            final status = ride['status'] ?? 'pending';
            final pickup = ride['pickup']?['name'] ?? 'N/A';
            final destination = ride['destination']?['name'] ?? 'N/A';
            final passenger = ride['passengerId'] ?? 'N/A';
            final driver = ride['driverName'] ?? 'N/A';

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("Ride: $pickup → $destination"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Passenger: $passenger"),
                    Text("Driver: $driver"),
                    Text("Status: $status"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 📊 Statistics Tab
  Widget _statisticsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(ridesCollection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rides = snapshot.data?.docs ?? [];

        final totalRides = rides.length;
        final acceptedRides = rides
            .where((r) =>
                (r.data() as Map<String, dynamic>)['status'] == 'accepted')
            .length;
        final rejectedRides = rides
            .where((r) =>
                (r.data() as Map<String, dynamic>)['status'] == 'rejected')
            .length;
        final requestedRides = rides
            .where((r) =>
                (r.data() as Map<String, dynamic>)['status'] == 'requested')
            .length;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Rides: $totalRides",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text("Accepted Rides: $acceptedRides",
                  style: const TextStyle(fontSize: 18, color: Colors.green)),
              const SizedBox(height: 12),
              Text("Rejected Rides: $rejectedRides",
                  style: const TextStyle(fontSize: 18, color: Colors.red)),
              const SizedBox(height: 12),
              Text("Requested Rides: $requestedRides",
                  style: const TextStyle(fontSize: 18, color: Colors.orange)),
            ],
          ),
        );
      },
    );
  }
}
