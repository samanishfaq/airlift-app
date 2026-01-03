import 'package:airlift/app/controllers/auth_controller.dart';
import 'package:airlift/app/ui/screens/welcome_screen/welcome.dart';
import 'package:airlift/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/data/translation/translation_service.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(AuthController(), permanent: true);

  try {
    runApp(
      const MyApp(),
    );
  } on Exception catch (e) {
    Logger.error(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      translations: TranslationService.instance,
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          fontFamily: GoogleFonts.inter().fontFamily),
      home: WelcomeScreen(),
    );
  }
}
