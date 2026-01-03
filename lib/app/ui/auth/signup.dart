import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airlift/app/controllers/auth_controller.dart';
import 'package:airlift/app/ui/auth/login.dart';
import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:airlift/commons/validator.dart';
import 'package:airlift/utils/text_field_decoration.dart';

class SignupPage extends StatefulWidget {
  final String userType; // "passenger" or "driver"
  const SignupPage({super.key, required this.userType});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final AuthController authController;
  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
    authController.clearFormData();

    if (widget.userType != 'passenger' && widget.userType != 'driver') {
      Future.microtask(() {
        Get.back();
        Get.snackbar(
          'Invalid User Type',
          'Sign Up is only allowed for Passenger or Driver',
          backgroundColor: AppColors.alertRed,
          colorText: AppColors.textWhite,
        );
      });
    }
  }

  String get userTypeTitle =>
      widget.userType == 'driver' ? 'Driver' : 'Passenger';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: size.height,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(35),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 70),
              child: IntrinsicHeight(
                child: Form(
                  key: authController.signupFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      AppText(
                        text: 'Create Account',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                        isHeading: true,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        text: 'Sign up as $userTypeTitle',
                        fontSize: 16,
                        color: Colors.grey[300]!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),

                      _buildTextField(
                        controller: authController.usernameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (v) =>
                            v!.isEmpty ? 'Full name required' : null,
                      ),
                      _buildTextField(
                        controller: authController.emailController,
                        label: 'Email',
                        icon: Icons.email,
                        validator: Appvalidator.validateEmail,
                      ),
                      _buildTextField(
                        controller: authController.phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Phone required' : null,
                      ),

                      Obx(() => _buildTextField(
                            controller: authController.passwordController,
                            label: 'Password',
                            icon: Icons.lock,
                            obscure: !authController.isPasswordVisible.value,
                            suffix: IconButton(
                              icon: Icon(
                                authController.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.textWhite,
                              ),
                              onPressed:
                                  authController.togglePasswordVisibility,
                            ),
                            validator: Appvalidator.validatePassword,
                          )),
                      _buildTextField(
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (v) =>
                            v != authController.passwordController.text
                                ? 'Passwords do not match'
                                : null,
                      ),

                      // ---------------- DRIVER FIELDS ----------------
                      if (widget.userType == 'driver') ...[
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white54),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: authController.licenseController,
                          label: 'License Number',
                          icon: Icons.card_membership,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        _buildTextField(
                          controller: authController.vehicleNumberController,
                          label: 'Vehicle Number',
                          icon: Icons.directions_car,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedVehicleType,
                          decoration:
                              inputDecoration(hintText: 'Select vehicle type')
                                  .copyWith(
                            labelText: 'Vehicle Type',
                            prefixIcon: const Icon(Icons.category,
                                color: AppColors.textWhite),
                          ),
                          dropdownColor: AppColors.bgDark,
                          style: const TextStyle(color: AppColors.textWhite),
                          items: const [
                            DropdownMenuItem(
                                value: 'Economy', child: Text('Economy')),
                            DropdownMenuItem(
                                value: 'Premium', child: Text('Premium')),
                            DropdownMenuItem(value: 'XL', child: Text('XL')),
                            DropdownMenuItem(
                                value: 'Luxury', child: Text('Luxury')),
                          ],
                          onChanged: (v) {
                            _selectedVehicleType = v;
                            authController.vehicleTypeController.text = v ?? '';
                          },
                          validator: (v) =>
                              v == null ? 'Select vehicle type' : null,
                        ),
                        const SizedBox(height: 16),
                        Obx(() => _buildDocumentPicker(
                              title: 'Upload License Document',
                              file: authController.licenseDoc.value,
                              onTap: () async {
                                final file =
                                    await authController.pickDocument();
                                if (file != null)
                                  authController.licenseDoc.value = file;
                              },
                            )),
                        const SizedBox(height: 16),
                        Obx(() => _buildDocumentPicker(
                              title: 'Upload Vehicle Registration',
                              file: authController.vehicleRegDoc.value,
                              onTap: () async {
                                final file =
                                    await authController.pickDocument();
                                if (file != null)
                                  authController.vehicleRegDoc.value = file;
                              },
                            )),
                      ],

                      const SizedBox(height: 30),
                      Obx(() => ElevatedButton(
                            onPressed: authController.isLoadingSignup.value
                                ? null
                                : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: authController.isLoadingSignup.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Sign Up',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white)),
                          )),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                              text: 'Already have an account?',
                              color: Colors.grey[300]!),
                          TextButton(
                            onPressed: () => Get.to(
                                () => LoginPage(userType: widget.userType)),
                            child: const Text('Login',
                                style: TextStyle(color: AppColors.primaryBlue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- WIDGET HELPERS ----------------
  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: inputDecoration(hintText: label).copyWith(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.textWhite),
            suffixIcon: suffix,
          ),
          style: const TextStyle(color: AppColors.textWhite),
          validator: validator,
        ),
      );

  Widget _buildDocumentPicker({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(file != null ? Icons.check_circle : Icons.upload_file,
                  color: file != null ? Colors.green : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file != null ? 'File selected' : title,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _handleSignup() async {
    if (authController.signupFormKey.currentState!.validate()) {
      authController.vehicleTypeController.text = _selectedVehicleType ?? '';
      await authController.signup(widget.userType);
    }
  }
}
