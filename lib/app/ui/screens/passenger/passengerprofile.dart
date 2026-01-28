import 'package:airlift/app/controllers/auth_controller.dart';
import 'package:airlift/app/controllers/passengerprofilecontroller.dart';
import 'package:airlift/app/ui/auth/selection_type.dart';
import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Passengerprofile extends StatefulWidget {
  const Passengerprofile({super.key});

  @override
  State<Passengerprofile> createState() => _PassengerprofileState();
}

class _PassengerprofileState extends State<Passengerprofile> {
  @override
  Widget build(BuildContext context) {
    final PassengerProfileController controller =
        Get.put(PassengerProfileController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: AppText(
          text: "Profile",
          color: AppColors.textWhite,
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () {
        //       // You can use AuthController to logout
        //       Get.find<AuthController>().logout();
        //     },
        //   )
        // ],
      ),
      body: StreamBuilder(
        stream: controller.passengerProfileStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data()!;
          final imageUrl = data['profileImage'] ?? '';
          final username = data['username'] ?? '';
          final email = data['email'] ?? '';
          final phone = data['phone'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() => Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : const AssetImage('assets/images/user.png')
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: controller.pickAndUploadProfileImage,
                            child: const CircleAvatar(
                              radius: 18,
                              child: Icon(Icons.camera_alt, size: 18),
                            ),
                          ),
                        ),
                        if (controller.isUploadingImage.value)
                          Positioned.fill(
                            child: Container(
                              color: AppColors.primaryBlue,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    )),
                const SizedBox(height: 20),
                Card(
                    color: AppColors.primaryBlue,
                    child: _infoTile("Name", username)),
                Card(
                    color: AppColors.primaryBlue,
                    child: _infoTile("Email", email)),
                Card(
                    color: AppColors.primaryBlue,
                    child: _infoTile("Phone", phone)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // 1. Log out user
                      await Get.find<AuthController>().logout();

                      Get.offAll(SelectionType());
                    },
                    child: AppText(
                      text: "Log Out",
                      color: AppColors.primaryBlue,
                      isHeading: true,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return ListTile(
        title: AppText(
          text: title,
          color: AppColors.bgDark,
          fontWeight: FontWeight.bold,
          isHeading: true,
          fontSize: 16,
        ),
        subtitle: AppText(
          text: value,
          color: AppColors.textWhite,
        ));
  }
}
