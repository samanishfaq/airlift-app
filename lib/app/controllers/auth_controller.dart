import 'dart:io';
import 'package:airlift/app/ui/screens/driver/driverdashboard.dart';
import 'package:airlift/app/ui/screens/driver/driverhome.dart';
import 'package:airlift/app/ui/screens/passenger/passengerdashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/cloudinary.dart';
import '../../utils/getx_snackbar.dart';
import '../../utils/logger.dart';

class AuthController extends GetxController {
  // Firebase & Storage
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Observables
  final RxBool isLoadingLogin = false.obs;
  final RxBool isLoadingSignup = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString userType = ''.obs;
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

  final ImagePicker _picker = ImagePicker();

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

  Future<File?> pickDocument() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) return File(pickedFile.path);
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

      // await _storage.writeAll({
      //   'userId': user.uid,
      //   'userType': type,
      //   'userEmail': emailController.text.trim(),
      //   'isLoggedIn': true,
      // });

      clearFormData();
      currentUser.value = user;
      Snack.showSuccessSnackBar('Login successful');
      _navigateAfterLogin(type);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoadingLogin.value = false;
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
      if (type == 'driver' &&
          (licenseDoc.value == null || vehicleRegDoc.value == null)) {
        Snack.showErrorSnackBar("Upload all required documents");
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

      // await _storage.writeAll({
      //   'userId': user.uid,
      //   'userType': type,
      //   'userEmail': emailController.text.trim(),
      //   'isLoggedIn': true,
      // });

      clearFormData();
      currentUser.value = user;
      Snack.showSuccessSnackBar('Account created successfully!');
      _navigateAfterLogin(type);
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'email-already-in-use'
          ? 'Email already in use'
          : e.code == 'weak-password'
              ? 'Weak password'
              : e.message ?? 'Sign up failed';
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
      Get.offAllNamed('/login-select');
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
