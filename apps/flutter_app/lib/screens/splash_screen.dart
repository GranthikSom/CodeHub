import 'package:flutter/material.dart';
import '../services/codehub_state.dart';
import 'dashboard_screen.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  final CodeHubState? state;
  const SplashScreen({super.key, this.state});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // Navigate after 2.5 seconds (preserving app state)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        if (widget.state?.api.isAuthenticated == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => DashboardScreen(state: widget.state)),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LandingScreen(state: widget.state)),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const creamBg = Color(0xFFFBF9F1);
    const sectionBg = Color(0xFFF4EFE6);
    const darkForestText = Color(0xFF19241E);
    const sageGreyText = Color(0xFF4A554D);
    const deepSageAccent = Color(0xFF2C5E43);
    const forestGreenPrimary = Color(0xFF1E3A2B);
    const sageMistBg = Color(0xFFE8F0EA);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [creamBg, sectionBg],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: sageMistBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: deepSageAccent.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: darkForestText.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    size: 72,
                    color: deepSageAccent,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'CODEHUB',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: darkForestText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Decentralized P2P Code Hosting Platform',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: sageGreyText,
                  ),
                ),
                const SizedBox(height: 54),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(forestGreenPrimary),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Initializing native P2P Rust Engine...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: sageGreyText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
