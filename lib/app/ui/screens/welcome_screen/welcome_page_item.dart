import 'package:airlift/app/ui/shared/text_widget.dart';
import 'package:airlift/commons/colors.dart';
import 'package:flutter/material.dart';

class WelcomePageItem extends StatelessWidget {
  const WelcomePageItem({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });

  final String image;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// IMAGE
          Container(
            width: double.infinity,
            height: size.height * 0.38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 40),

          /// TITLE (Urbanist)
          AppText(
            text: title,
            isHeading: true,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
            letterSpacing: 1.2,
          ),

          const SizedBox(height: 18),

          /// DESCRIPTION (Inter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppText(
              text: description,
              fontSize: 16,
              textAlign: TextAlign.center,
              height: 1.5,
              color: AppColors.textWhite.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 40),

          /// ICON
          // Icon(
          //   Icons.directions_car_rounded,
          //   color: color,
          //   size: 48,
          // ),
        ],
      ),
    );
  }
}
