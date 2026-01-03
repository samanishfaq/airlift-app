import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airlift/commons/assets.dart';
import 'package:airlift/commons/colors.dart';

class WelcomeController extends GetxController {
  final PageController pageController = PageController();

  final RxInt currentIndex = 0.obs;

  final List<Map<String, dynamic>> pages = [
    {
      'image': AppAssets.ride,
      'title': 'Fast & Safe Rides',
      'description':
          'Experience comfortable rides with top-rated drivers anytime, anywhere',
      'color': AppColors.primaryBlue,
    },
    {
      'image': AppAssets.drive,
      'title': 'Professional Drivers',
      'description':
          'Our verified drivers ensure your safety and comfort throughout the journey',
      'color': AppColors.primaryBlue,
    },
    {
      'image': AppAssets.trcker,
      'title': 'Live Tracking',
      'description': 'Track your ride in real-time with accurate GPS location',
      'color': AppColors.primaryBlue,
    },
  ];

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startAutoSlide();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    _startAutoSlide();
  }

  void nextPage() {
  if (pageController.hasClients && currentIndex.value < pages.length - 1) {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

 void _startAutoSlide() {
  _timer?.cancel();
  _timer = Timer(const Duration(seconds: 5), () {
    if (pageController.hasClients && currentIndex.value < pages.length - 1) {
      nextPage();
    }
  });
}


  bool get isLastPage => currentIndex.value == pages.length - 1;

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
