import 'package:get/get.dart';
import 'package:airlift/app/ui/auth/login.dart';

class SelectionTypeController extends GetxController {
  void navigateToAuth(String userType) {
    Get.to(() => LoginPage(userType: userType));
  }
}
