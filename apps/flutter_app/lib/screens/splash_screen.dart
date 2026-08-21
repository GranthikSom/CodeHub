import 'package:flutter/material.dart';

import '../services/codehub_state.dart';
import 'dashboard_screen.dart';

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

    // Navigate to DashboardScreen after 2.5 seconds (preserving app state)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(state: widget.state)),
        );
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: const Icon(
                  Icons.hub,
                  size: 72,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CODEHUB',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Decentralized P2P Code Hosting Platform',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Initializing native P2P Rust Engine...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
