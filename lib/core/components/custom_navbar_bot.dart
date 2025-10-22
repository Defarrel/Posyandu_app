import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';

class CustomNavbarBot extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbarBot({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = AppColors.primary;

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context: context,
            icon: CupertinoIcons.person_crop_circle_badge_plus,
            index: 0,
            isActive: currentIndex == 0,
            onTap: () => HomeRoot.navigateToTab(context, 0),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.home_outlined,
            index: 1,
            isActive: currentIndex == 1,
            onTap: () => HomeRoot.navigateToTab(context, 1),
          ),
          _buildNavItem(
            context: context,
            icon: CupertinoIcons.doc_text,
            index: 2,
            isActive: currentIndex == 2,
            onTap: () => HomeRoot.navigateToTab(context, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, isActive ? -12 : 0, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.transparent,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isActive ? AppColors.primaryDark : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
