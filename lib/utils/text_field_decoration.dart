import 'package:flutter/material.dart';
import '../commons/colors.dart';

InputDecoration inputDecoration({required String hintText}) => InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.textWhite, fontSize: 16),
      contentPadding:
          const EdgeInsets.only(right: 15, left: 25, top: 2, bottom: 2),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.textWhite)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryBlue)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryBlue)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.alertRed)),
    );

InputDecorationTheme inputDecorationTheme() => InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.textWhite, fontSize: 16),
      contentPadding:
          const EdgeInsets.only(right: 15, left: 25, top: 2, bottom: 2),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryBlue)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.alertRed)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.alertRed)),
    );

InputDecoration inputDecorationSearch(
        {required String hintText,
        required VoidCallback onPressed,
        Color borderColor = Colors.white}) =>
    InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: borderColor, fontSize: 16),
      suffixIcon: IconButton(
          onPressed: onPressed,
          icon: Icon(
            Icons.cancel,
            color: borderColor,
          )),
      contentPadding:
          const EdgeInsets.only(right: 15, left: 25, top: 2, bottom: 2),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.alertRed)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.alertRed)),
    );
