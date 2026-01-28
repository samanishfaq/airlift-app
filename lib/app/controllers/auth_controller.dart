import 'dart:io';
import 'package:airlift/utils/cloudinary.dart';
import 'package:airlift/utils/getx_snackbar.dart';
import 'package:airlift/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:airlift/app/ui/screens/driver/driverdashboard.dart';
import 'package:airlift/app/ui/screens/passenger/passengerdashboard.dart';
import 'package:airlift/app/ui/screens/admin/admindashboard.dart';

class AuthController extends GetxController {
  // Firebase & Storage
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Observables
  final RxBool isLoadingLogin = false.obs;
  final RxBool isLoadingSignup = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString userType = ''.obs; // passenger / driver / admin
  final Rx<User?> currentUser = Rx<User?>(null);

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final licenseController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final vehicleTypeController = TextEditingController();

  // Driver documents
  final Rx<File?> licenseDoc = Rx<File?>(null);
  final Rx<File?> vehicleRegDoc = Rx<File?>(null);

  // ---------------- UTILITIES ----------------
  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void clearFormData() {
    emailController.clear();
    passwordController.clear();
    usernameController.clear();
    phoneController.clear();
    licenseController.clear();
    vehicleNumberController.clear();
    vehicleTypeController.clear();
    licenseDoc.value = null;
    vehicleRegDoc.value = null;
  }

  /// Pick PDF document only
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      Logger.error('Error picking document: $e');
      Snack.showErrorSnackBar('Failed to pick document');
    }
    return null;
  }

  Future<String> _uploadFile(File file) async {
    try {
      return await CloudinaryService().uploadFile(file);
    } catch (e) {
      Logger.error('Upload failed: $e');
      throw Exception('File upload failed');
    }
  }

  // ---------------- LOGIN ----------------
  Future<void> login(String type) async {
    isLoadingLogin.value = true;
    userType.value = type;

    if (!(loginFormKey.currentState?.validate() ?? false)) {
      isLoadingLogin.value = false;
      return;
    }

    try {
      if (type == 'admin') {
        await _loginAdmin(
            emailController.text.trim(), passwordController.text.trim());
      } else {
        await _loginUser(type);
      }
    } finally {
      isLoadingLogin.value = false;
    }
  }

  // ---------------- ADMIN LOGIN ----------------
  Future<void> _loginAdmin(String email, String password) async {
    try {
      final adminQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password) // plaintext for testing
          .get();

      if (adminQuery.docs.isEmpty) {
        Snack.showErrorSnackBar("Invalid admin credentials");
        return;
      }

      userType.value = 'admin';
      Snack.showSuccessSnackBar("Admin login successful");
      clearFormData();
      Get.offAll(() => AdminDashboard());
    } catch (e) {
      Snack.showErrorSnackBar("Error logging in admin: $e");
    }
  }

  // ---------------- DRIVER / PASSENGER LOGIN ----------------
  Future<void> _loginUser(String type) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user!;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data()?['userType'] != type) {
        await _auth.signOut();
        Snack.showErrorSnackBar('Invalid account type');
        return;
      }

      clearFormData();
      currentUser.value = user;
      Snack.showSuccessSnackBar('Login successful');
      _navigateAfterLogin(type);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    }
  }

  // ---------------- SIGNUP ----------------
  Future<void> signup(String type) async {
    isLoadingSignup.value = true;
    userType.value = type;

    if (!(signupFormKey.currentState?.validate() ?? false)) {
      isLoadingSignup.value = false;
      return;
    }

    try {
      // Ensure driver documents are uploaded
      if (type == 'driver' &&
          (licenseDoc.value == null || vehicleRegDoc.value == null)) {
        Snack.showErrorSnackBar("Upload all required PDF documents");
        isLoadingSignup.value = false;
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user!;
      String? licenseUrl;
      String? vehicleUrl;

      if (type == 'driver') {
        licenseUrl = await _uploadFile(licenseDoc.value!);
        vehicleUrl = await _uploadFile(vehicleRegDoc.value!);
      }

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'userType': type,
        'licenseNumber': licenseController.text.trim(),
        'vehicleNumber': vehicleNumberController.text.trim(),
        'vehicleType': vehicleTypeController.text.trim(),
        'licenseDoc': licenseUrl ?? '',
        'vehicleRegDoc': vehicleUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      clearFormData();
      currentUser.value = user;
      Snack.showSuccessSnackBar('Account created successfully!');
      _navigateAfterLogin(type);
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'email-already-in-use' => 'Email already in use',
        'weak-password' => 'Weak password',
        _ => e.message ?? 'Sign up failed',
      };
      Snack.showErrorSnackBar(message);
    } finally {
      isLoadingSignup.value = false;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _storage.erase();
      currentUser.value = null;
      userType.value = '';
      Get.offAllNamed('/login-select'); // go to type selection screen
    } catch (e) {
      Logger.error('Logout failed: $e');
      Snack.showErrorSnackBar('Logout failed');
    }
  }

  // ---------------- NAVIGATION ----------------
  void _navigateAfterLogin(String type) {
    switch (type) {
      case 'passenger':
        Get.offAll(() => Passengerdashboard());
        break;
      case 'driver':
        Get.offAll(() => DriverDashboard());
        break;
      case 'admin':
        Get.offAll(() => AdminDashboard());
        break;
      default:
        Get.offAllNamed('/home');
    }
  }

  // ---------------- HELPERS ----------------
  void _handleAuthError(FirebaseAuthException e) {
    String message = switch (e.code) {
      'user-not-found' => 'No user found for this email',
      'wrong-password' => 'Incorrect password',
      'invalid-email' => 'Invalid email',
      'user-disabled' => 'Account disabled',
      'too-many-requests' => 'Too many attempts',
      _ => e.message ?? 'Authentication failed',
    };
    Snack.showErrorSnackBar(message);
  }

  @override
  void onInit() async {
    super.onInit();
    final isLoggedIn = _storage.read('isLoggedIn') ?? false;
    if (isLoggedIn && _auth.currentUser != null) {
      currentUser.value = _auth.currentUser;
      userType.value = _storage.read('userType') ?? '';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    licenseController.dispose();
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    super.onClose();
  }
}
