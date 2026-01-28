import 'dart:io';
import 'package:airlift/app/ui/auth/selection_type.dart';
import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:airlift/utils/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool uploading = false;

  Future<void> _updateProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => uploading = true);

    final url = await CloudinaryService().uploadFile(File(picked.path));

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImage': url,
    });

    setState(() => uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          centerTitle: true,
          title: const AppText(
            text: "Driver Profile",
            color: AppColors.textWhite,
            isHeading: true,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || !snap.data!.exists) {
            return const Center(
              child: Text("Profile not found"),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: data['profileImage'] != null &&
                              data['profileImage'] != ''
                          ? NetworkImage(data['profileImage'])
                          : null,
                      child: data['profileImage'] == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: uploading ? null : _updateProfileImage,
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryBlue,
                          child:
                              Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _tile("Name", data['username']),
                _tile("Email", data['email']),
                _tile("Phone", data['phone']),
                _tile("Vehicle", data['vehicleType']),
                _tile("Vehicle No", data['vehicleNumber']),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textWhite,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const AppText(
                    text: "Logout",
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAll(SelectionType());
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tile(String title, String value) {
    return Card(
      color: AppColors.primaryBlue,
      child: ListTile(
        title: AppText(
          text: title,
          color: AppColors.textWhite,
          isHeading: true,
          fontWeight: FontWeight.bold,
        ),
        subtitle: AppText(
          text: value.isEmpty ? 'N/A' : value,
          color: AppColors.textWhite,
        ),
      ),
    );
  }
}
