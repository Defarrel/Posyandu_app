import 'package:flutter/material.dart';
import 'package:posyandu_app/presentation/balita/cari_balita_screen.dart';
import 'package:posyandu_app/presentation/balita/tambah_balita_screen.dart';
import 'package:posyandu_app/presentation/home/home_screen.dart';
import 'package:posyandu_app/core/components/custom_navbar_bot.dart';

class HomeRoot extends StatefulWidget {
  const HomeRoot({super.key});

  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomeRootState>();
    state?._onTap(index);
  }

  @override
  State<HomeRoot> createState() => _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> with TickerProviderStateMixin {
  int _currentIndex = 1;

  late final List<Widget> _screens = [
    const TambahBalitaScreen(),
    const HomeScreen(),
    const CariBalitaScreen(),
  ];

  late final List<AnimationController> _fadeControllers = List.generate(
    _screens.length,
    (index) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    ),
  );

  late final List<Animation<double>> _fadeAnimations = _fadeControllers
      .map(
        (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(controller),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _fadeControllers[_currentIndex].forward();
  }

  void _onTap(int index) {
    if (index != _currentIndex) {
      _fadeControllers[_currentIndex].reverse();
      _fadeControllers[index].forward();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _fadeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: List.generate(_screens.length, (index) {
          return IgnorePointer(
            ignoring: _currentIndex != index,
            child: FadeTransition(
              opacity: _fadeAnimations[index],
              child: Offstage(
                offstage: _currentIndex != index,
                child: _screens[index],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: CustomNavbarBot(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
