import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
    const Color activeColor = Color(0xFF2196F3); // Biru aktif
    const Color inactiveColor = Colors.grey;

    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: CupertinoIcons.person_crop_circle_badge_plus,
            index: 0,
            isActive: currentIndex == 0,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavItem(
            icon: Icons.home,
            index: 1,
            isActive: currentIndex == 1,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavItem(
            icon: CupertinoIcons.doc_text,
            index: 2,
            isActive: currentIndex == 2,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 30,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}
