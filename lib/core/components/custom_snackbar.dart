import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar {
  static SnackBar show({
    required String message,
    SnackBarType type = SnackBarType.info,
  }) {
    Color bgColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;

      case SnackBarType.error:
        bgColor = Colors.red;
        icon = Icons.error_outline;
        break;

      default:
        bgColor = AppColors.primaryLight;
        icon = Icons.info_outline;
    }

    return SnackBar(
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    );
  }
}
