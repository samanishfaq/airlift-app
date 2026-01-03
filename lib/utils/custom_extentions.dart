import 'package:flutter/material.dart';

import '../app/ui/shared/text_widget.dart';
import '../commons/colors.dart';

extension StringExtensions on String {
  String capitalize() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1);
  }
}

extension ContextExtensions on BuildContext {
  double get w => MediaQuery.of(this).size.width;
  double get h => MediaQuery.of(this).size.height;

  ThemeData get themeContext => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        behavior: SnackBarBehavior.floating,
        content:
            AppText(text: message, color: Colors.white, fontSize: 16),
        backgroundColor: AppColors.successGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        behavior: SnackBarBehavior.floating,
        content:
            AppText(text: message, color: Colors.white, fontSize: 16),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showErrorSnackBar(String message,
      {String? actionLabel, VoidCallback? onPressed, int sec = 3}) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        behavior: SnackBarBehavior.floating,
        content:
            AppText(text: message, color: Colors.white, fontSize: 16),
        backgroundColor: AppColors.alertRed,
        actionOverflowThreshold: BorderSide.strokeAlignOutside,
        action: actionLabel == null && onPressed == null
            ? null
            : SnackBarAction(
                label: actionLabel!,
                onPressed: onPressed!,
                textColor: Colors.white,
              ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: sec),
      ),
    );
  }

  void hideKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(this);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    // FocusScope.of(this).unfocus();
  }
}
