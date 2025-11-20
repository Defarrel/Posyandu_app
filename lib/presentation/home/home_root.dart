import 'package:flutter/material.dart';
import 'package:posyandu_app/presentation/balita/cari_balita_screen.dart';
import 'package:posyandu_app/presentation/home/home_screen.dart';
import 'package:posyandu_app/presentation/profile/profile_screen.dart';
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

class _HomeRootState extends State<HomeRoot> {
  int _currentIndex = 1;
  bool _isNavigatingFromTap = false;

  late final PageController _pageController = PageController(
    initialPage: _currentIndex,
  );

  final List<Widget> _screens = const [
    CariBalitaScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;

    _isNavigatingFromTap = true;

    setState(() => _currentIndex = index);

    if ((index - _currentIndex).abs() > 1) {
      _pageController.jumpToPage(index);
      _isNavigatingFromTap = false;
    } else {
      _pageController
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          )
          .then((_) {
            _isNavigatingFromTap = false;
          });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (!_isNavigatingFromTap) {
            setState(() => _currentIndex = index);
          }
        },
        children: _screens.map((screen) {
          return _KeepAlivePage(child: screen);
        }).toList(),
      ),
      bottomNavigationBar: CustomNavbarBot(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
