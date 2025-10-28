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

class _HomeRootState extends State<HomeRoot> with TickerProviderStateMixin {
  int _currentIndex = 1;
  int _previousIndex = 1;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  final List<Widget> _screens = const [
    _KeepAlivePage(child: CariBalitaScreen()),
    _KeepAlivePage(child: HomeScreen()),
    _KeepAlivePage(child: ProfileScreen()),
  ];

  bool _firstRender = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
      _firstRender = false;
    });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Animasi geser kiri-kanan seperti semula
    final slideIn = Tween<Offset>(
      begin: Offset(_previousIndex < _currentIndex ? 1.0 : -1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(_previousIndex < _currentIndex ? -1.0 : 1.0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    final fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_firstRender) {
            return _screens[_currentIndex];
          }

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
                    child: _screens[index],
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
