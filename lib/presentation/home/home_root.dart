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
  late final PageController _pageController = PageController(
    initialPage: _currentIndex,
  );

  final List<Widget> _screens = const [
    _KeepAlivePage(child: CariBalitaScreen()),
    _KeepAlivePage(child: HomeScreen()),
    _KeepAlivePage(child: ProfileScreen()),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => PageView(
              controller: _pageController,
              physics: CustomPageViewScrollPhysics(
                currentIndex: _currentIndex,
                maxIndex: _screens.length - 1,
              ),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: _screens,
            ),
          );
        },
      ),
      bottomNavigationBar: CustomNavbarBot(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends BouncingScrollPhysics {
  final int currentIndex;
  final int maxIndex;

  const CustomPageViewScrollPhysics({
    required this.currentIndex,
    required this.maxIndex,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(
      currentIndex: currentIndex,
      maxIndex: maxIndex,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (currentIndex == 0 && value < position.pixels) {
      return value - position.pixels;
    }
    if (currentIndex == maxIndex && value > position.pixels) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
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
