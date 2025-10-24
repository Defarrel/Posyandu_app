import 'package:flutter/material.dart';
import 'package:posyandu_app/presentation/balita/cari_balita_screen.dart';
import 'package:posyandu_app/presentation/balita/tambah_balita_screen.dart';
import 'package:posyandu_app/presentation/home/home_screen.dart';
import 'package:posyandu_app/core/components/custom_navbar_bot.dart';
import 'package:posyandu_app/presentation/profile/profile_screen.dart';

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
  int _previousIndex = 1;

  final List<Widget> _screens = const [
    CariBalitaScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    3,
    (index) => GlobalKey<NavigatorState>(),
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) {
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }

    if (index == 1) {
      _navigatorKeys[1].currentState?.popUntil((r) => r.isFirst);
    }

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slideIn =
              Tween<Offset>(
                begin: Offset(_previousIndex < _currentIndex ? 1.0 : -1.0, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              );

          final slideOut =
              Tween<Offset>(
                begin: Offset.zero,
                end: Offset(_previousIndex < _currentIndex ? -1.0 : 1.0, 0),
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              );

          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );

          return Stack(
            children: List.generate(_screens.length, (index) {
              final isActive = index == _currentIndex;
              final isPrevious = index == _previousIndex;

              if (!isActive && !isPrevious) return const SizedBox.shrink();

              return Offstage(
                offstage: !isActive && !isPrevious,
                child: SlideTransition(
                  position: isActive ? slideIn : slideOut,
                  child: FadeTransition(
                    opacity: isActive ? fade : ReverseAnimation(fade),
                    child: Navigator(
                      key: _navigatorKeys[index],
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (_) => _screens[index],
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
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
