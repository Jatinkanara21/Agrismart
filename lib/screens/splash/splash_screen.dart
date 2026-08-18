import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  const SplashScreen({super.key, this.onToggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: .72, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const OnboardingScreen(), transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child)));
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale, child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 96, height: 96, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24)), child: const Icon(Icons.eco_rounded, color: Colors.white, size: 52)),
          const SizedBox(height: 22),
          const Text('AgriSmart', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 8),
          const Text('Smart farming. Better harvest.', style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 26),
          SizedBox(width: 86, child: LinearProgressIndicator(minHeight: 3, color: Colors.white, backgroundColor: Colors.white24, borderRadius: BorderRadius.circular(10))),
        ])))) ,
      ),
    );
  }
}
