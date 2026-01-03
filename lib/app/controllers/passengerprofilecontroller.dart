import 'dart:io';
import 'package:airlift/utils/cloudinary.dart';
import 'package:airlift/utils/getx_snackbar.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';


class PassengerProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  RxBool isUploadingImage = false.obs;

  Stream<DocumentSnapshot<Map<String, dynamic>>> passengerProfileStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> pickAndUploadProfileImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      isUploadingImage.value = true;

      File file = File(pickedFile.path);
      final imageUrl = await CloudinaryService().uploadFile(file);

      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'profileImage': imageUrl,
      });

      Snack.showSuccessSnackBar("Profile image updated");
    } catch (e) {
      Snack.showErrorSnackBar("Image upload failed");
    } finally {
      isUploadingImage.value = false;
    }
  }
}
