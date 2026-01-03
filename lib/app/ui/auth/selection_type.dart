import 'package:airlift/app/controllers/auth_controller.dart';
import 'package:airlift/app/controllers/selectiontypecontroller.dart';
import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionType extends StatelessWidget {
  SelectionType({super.key});

  final SelectionTypeController controller =
      Get.put(SelectionTypeController());

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'Choose Your Role',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          isHeading: true,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _headerSection(),
              _optionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              size: 60,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 24),
          const AppText(
            text: 'Welcome to AirLift',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            isHeading: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AppText(
            text: 'Select how you want to use the app',
            fontSize: 16,
            color: AppColors.textWhite.withOpacity(0.9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _optionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _userCard(
            icon: Icons.person_outline_rounded,
            title: 'Passenger',
            subtitle: 'Book rides for your travel needs',
            onTap: () => controller.navigateToAuth('passenger'),
          ),
          const SizedBox(height: 20),
          _userCard(
            icon: Icons.directions_car_filled_rounded,
            title: 'Driver',
            subtitle: 'Earn money by driving passengers',
            onTap: () => controller.navigateToAuth('driver'),
          ),
          const SizedBox(height: 20),
          _userCard(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin',
            subtitle: 'Manage the platform operations',
            onTap: () => controller.navigateToAuth('admin'),
          ),
          const SizedBox(height: 40),
          const AppText(
            text:
                'By continuing, you agree to our Terms of Service and Privacy Policy',
            fontSize: 12,
            color: AppColors.textWhite,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _userCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 30, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 5),
                  AppText(
                    text: subtitle,
                    fontSize: 14,
                    color: AppColors.textWhite.withOpacity(0.8),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}
