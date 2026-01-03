import 'package:airlift/app/controllers/welcomecontroller.dart';
import 'package:airlift/app/ui/auth/selection_type.dart';
import 'package:airlift/app/ui/screens/welcome_screen/welcome_page_item.dart';
import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final WelcomeController controller = Get.put(WelcomeController());

  void _goToSelectionType() {
    Get.off(() => SelectionType());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            /// PageView
            PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pages.length,
              onPageChanged: controller.onPageChanged,
              itemBuilder: (context, index) {
                final page = controller.pages[index];
                return WelcomePageItem(
                  image: page['image'],
                  title: page['title'],
                  description: page['description'],
                  color: page['color'],
                );
              },
            ),

            /// Skip Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: InkWell(
                onTap: _goToSelectionType,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const AppText(
                    text: 'Skip',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),

            /// Indicators
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: controller.currentIndex.value == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: controller.currentIndex.value == index
                            ? AppColors.primaryBlue
                            : AppColors.textWhite.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Next / Get Started Button
            Positioned(
              bottom: 70,
              left: 20,
              right: 20,
              child: Obx(
                () => ElevatedButton(
                  onPressed: () {
                    if (controller.isLastPage) {
                      _goToSelectionType();
                    } else {
                      controller.nextPage();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: AppText(
                    text: controller.isLastPage ? 'Get Started' : 'Next',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
