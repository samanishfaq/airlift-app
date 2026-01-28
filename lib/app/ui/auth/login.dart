import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airlift/app/controllers/auth_controller.dart';
import 'package:airlift/app/ui/auth/signup.dart';
import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:airlift/commons/validator.dart';
import 'package:airlift/utils/text_field_decoration.dart';

class LoginPage extends StatefulWidget {
  final String userType; // passenger / driver / admin
  const LoginPage({super.key, required this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
    authController.clearFormData();
  }

  String get userTypeTitle {
    switch (widget.userType) {
      case 'passenger':
        return 'Passenger';
      case 'driver':
        return 'Driver';
      case 'admin':
        return 'Admin';
      default:
        return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            height: double.infinity,
            width: double.infinity,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(35),
              child: Form(
                key: authController.loginFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    AppText(
                      text: 'Welcome Back',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                      isHeading: true,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AppText(
                      text: 'Login as $userTypeTitle',
                      fontSize: 16,
                      color: Colors.grey[300]!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    _buildTextField(
                      controller: authController.emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Appvalidator.validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
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
                            onPressed: authController.togglePasswordVisibility,
                          ),
                          validator: Appvalidator.validatePassword,
                          onFieldSubmitted: (_) => _handleLogin(),
                        )),
                    const SizedBox(height: 30),

                    // Login Button
                    Obx(() => ElevatedButton(
                          onPressed: authController.isLoadingLogin.value
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authController.isLoadingLogin.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : AppText(
                                  text: "Login",
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                        )),
                    const SizedBox(height: 25),

                    // OR Divider
                    if (widget.userType != 'admin')
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[600],
                              thickness: 0.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AppText(
                              text: 'OR',
                              color: Colors.grey[400]!,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[600],
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 25),

                    // Sign Up Link (Not for admin)
                    if (widget.userType == 'driver' ||
                        widget.userType == 'passenger')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            text: "Don't have an account?",
                            color: Colors.grey[300]!,
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(
                                  () => SignupPage(userType: widget.userType));
                            },
                            child: AppText(
                              text: 'Sign Up',
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              isHeading: true,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Back button
                    TextButton(
                      onPressed: () => Get.back(),
                      child: AppText(
                        text: '← Back to Selection',
                        color: Colors.grey[400]!,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
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
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Future<void> _handleLogin() async {
    if (authController.loginFormKey.currentState!.validate()) {
      await authController.login(widget.userType);
    } else {
      Get.snackbar(
        'Invalid Form',
        'Please fill all required fields correctly',
        backgroundColor: AppColors.alertRed,
        colorText: AppColors.textWhite,
      );
    }
  }
}
