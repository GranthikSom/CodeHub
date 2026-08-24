import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/codehub_state.dart';
import 'dashboard_screen.dart';

class LandingScreen extends StatefulWidget {
  final CodeHubState? state;

  const LandingScreen({super.key, this.state});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isSignUpMode = true;
  bool _isLoading = false;

  final _usernameController = TextEditingController(text: 'cyberduck');
  final _emailController = TextEditingController(text: 'cyberduck@codehub.com');
  final _passwordController = TextEditingController(text: 'password12345678');

  final ApiService _fallbackApi = ApiService();
  ApiService get _api => widget.state?.api ?? _fallbackApi;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in username and password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> response;
    if (_isSignUpMode) {
      response = await _api.register(
        username: username,
        email: email.isNotEmpty ? email : '$username@codehub.com',
        password: password,
      );
    } else {
      response = await _api.login(username: username, password: password);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response['success'] == true) {
      widget.state?.notifyAuthStateChanged();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => DashboardScreen(state: widget.state)),
        (route) => false,
      );
    } else {
      final errMsg = response['message'] ?? 'Authentication failed. Please check your credentials.';
      final isAlreadyRegistered = errMsg.toString().toLowerCase().contains('already registered') ||
          errMsg.toString().toLowerCase().contains('already exists');

      if (isAlreadyRegistered && _isSignUpMode) {
        setState(() {
          _isSignUpMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Account '$username' already exists. Switched to Sign In mode.",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2C5E43),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errMsg.toString())),
              ],
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warm Ivory & Deep Sage Color System
    const creamBg = Color(0xFFFBF9F1);
    const cardBg = Color(0xFFFFFDF5);
    const sectionBg = Color(0xFFF4EFE6);
    const beigeBorder = Color(0xFFE5E0D8);

    const darkForestText = Color(0xFF19241E);
    const sageGreyText = Color(0xFF4A554D);
    const deepSageAccent = Color(0xFF2C5E43);
    const forestGreenPrimary = Color(0xFF1E3A2B);
    const sageMistBg = Color(0xFFE8F0EA);

    return Scaffold(
      backgroundColor: creamBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Navigation Bar (Warm Ivory & Deep Sage)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: const BoxDecoration(
                color: creamBg,
                border: Border(bottom: BorderSide(color: beigeBorder, width: 1)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Row(
                    children: [
                      // CodeHub Logo
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sageMistBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: deepSageAccent.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.hub_rounded, size: 24, color: deepSageAccent),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'CodeHub',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: darkForestText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: sageMistBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: deepSageAccent.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'P2P Swarm v1.4',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: deepSageAccent),
                        ),
                      ),
                      const SizedBox(width: 36),

                      // Nav Menu Items
                      _buildNavItem('Features', darkForestText),
                      _buildNavItem('Architecture', darkForestText),
                      _buildNavItem('Swarm Stats', darkForestText),
                      _buildNavItem('Enterprise', darkForestText),

                      const Spacer(),

                      // Sign In link
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUpMode = false;
                          });
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: !_isSignUpMode ? deepSageAccent : darkForestText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sign Up Button (Forest Green)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: forestGreenPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSignUpMode = true;
                          });
                        },
                        child: const Text('Sign up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Full-Width Hero Section (Cream / Warm Ivory & Deep Sage Gradient)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [creamBg, sectionBg],
                ),
                border: Border(bottom: BorderSide(color: beigeBorder, width: 1)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Hero Text & Enterprise Box
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: sageMistBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: deepSageAccent.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, color: deepSageAccent, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Sovereign P2P Infrastructure • Zero Lock-in',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: deepSageAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 62,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                  letterSpacing: -2.0,
                                  color: darkForestText,
                                  fontFamily: 'sans-serif',
                                ),
                                children: [
                                  TextSpan(text: 'Built for '),
                                  TextSpan(
                                    text: '>_',
                                    style: TextStyle(color: deepSageAccent),
                                  ),
                                  TextSpan(text: '\nDevelopers'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "CodeHub is the world's most secure, most scalable, and most loved sovereign P2P developer platform. Host, replicate, and collaborate on Git repositories using content-addressed SHA-256 DAG trees and libp2p Gossipsub.",
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.5,
                                color: sageGreyText,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Enterprise Callout Card (Warm Ivory / Sage)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: beigeBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkForestText.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: sageMistBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: beigeBorder),
                                    ),
                                    child: const Icon(Icons.corporate_fare_outlined, size: 28, color: forestGreenPrimary),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CodeHub Enterprise Swarm',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: darkForestText,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Deploy to your private environment or self-hosted cloud.',
                                          style: TextStyle(fontSize: 13, color: sageGreyText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Row(
                                      children: [
                                        Text('Start trial', style: TextStyle(color: deepSageAccent, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward, size: 14, color: deepSageAccent),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),

                      // Center Column: Git Branch DAG Graphic
                      SizedBox(
                        width: 120,
                        height: 480,
                        child: CustomPaint(
                          painter: GitBranchGraphPainter(),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Right Column: Auth Card (Warm Ivory & Deep Sage)
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: beigeBorder),
                            boxShadow: [
                              BoxShadow(
                                color: darkForestText.withValues(alpha: 0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: forestGreenPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.fork_right_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    _isSignUpMode ? 'Get started' : 'Sign in',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: darkForestText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // Timeline & Inputs
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      _buildStepDot(true, forestGreenPrimary),
                                      _buildStepLine(50, beigeBorder),
                                      _buildStepDot(_isSignUpMode, forestGreenPrimary),
                                      _buildStepLine(50, beigeBorder),
                                      _buildStepDot(false, forestGreenPrimary),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: _usernameController,
                                          style: const TextStyle(color: darkForestText, fontSize: 15, fontWeight: FontWeight.w500),
                                          decoration: const InputDecoration(
                                            labelText: 'Username',
                                            labelStyle: TextStyle(color: sageGreyText),
                                            hintText: '@cyberduck',
                                            hintStyle: TextStyle(color: Colors.black26),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: beigeBorder)),
                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: deepSageAccent, width: 2)),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _emailController,
                                          style: const TextStyle(color: darkForestText, fontSize: 15, fontWeight: FontWeight.w500),
                                          decoration: const InputDecoration(
                                            labelText: 'Email Address',
                                            labelStyle: TextStyle(color: sageGreyText),
                                            hintText: 'cyberduck@codehub.com',
                                            hintStyle: TextStyle(color: Colors.black26),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: beigeBorder)),
                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: deepSageAccent, width: 2)),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: const TextStyle(color: darkForestText, fontSize: 15, fontWeight: FontWeight.w500),
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: TextStyle(color: sageGreyText),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: beigeBorder)),
                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: deepSageAccent, width: 2)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Make sure it's at least 15 characters. Learn more.",
                                style: TextStyle(fontSize: 11, color: sageGreyText),
                              ),
                              const SizedBox(height: 28),

                              // Big Deep Sage / Forest Green Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: forestGreenPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading ? null : _submitAuth,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(
                                          _isSignUpMode ? 'Sign up for CodeHub' : 'Sign in to CodeHub',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _isSignUpMode
                                    ? 'By clicking "Sign up for CodeHub", you agree to our Terms of Service and Privacy Statement.'
                                    : 'By clicking "Sign in to CodeHub", you authenticate using zero-plain identity keys.',
                                style: const TextStyle(fontSize: 11, color: sageGreyText, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Swarm Metrics Counter Bar (Warm Deep Cream)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              color: sectionBg,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetricCard('14 Active Nodes', 'Kademlia DHT Mesh', Icons.lan, forestGreenPrimary, darkForestText, sageGreyText),
                      _buildMetricCard('100% Encrypted', 'Noise TLS Handshake', Icons.shield, deepSageAccent, darkForestText, sageGreyText),
                      _buildMetricCard('450 MB/s Engine', 'Rabin Chunking Speed', Icons.speed, const Color(0xFF386641), darkForestText, sageGreyText),
                      _buildMetricCard('24 ms Latency', 'Gossipsub Broadcast', Icons.bolt, const Color(0xFF8B5A2B), darkForestText, sageGreyText),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Live P2P Swarm Terminal Box (Forest Black Window inside Cream Container)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: const BoxDecoration(
                color: creamBg,
                border: Border(
                  top: BorderSide(color: beigeBorder),
                  bottom: BorderSide(color: beigeBorder),
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14241B), // Dark Deep Forest Window
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C4C3B)),
                    boxShadow: [
                      BoxShadow(
                        color: darkForestText.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                          const SizedBox(width: 16),
                          const Text('codehub-p2p-engine — bash — 80x24', style: TextStyle(color: Color(0xFFAFE3C0), fontSize: 13, fontFamily: 'monospace')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('\$ codehub swarm join --peer 127.0.0.1:8080', style: TextStyle(color: Color(0xFF86D6A3), fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('[INFO] Noise TLS v1.3 Handshake completed with seed node 12D3KooW...', style: TextStyle(color: Color(0xFFAFE3C0), fontSize: 13, fontFamily: 'monospace')),
                      const SizedBox(height: 4),
                      const Text('[INFO] Kademlia DHT routing table refreshed: 14 active peers online', style: TextStyle(color: Color(0xFF6BBF8F), fontSize: 13, fontFamily: 'monospace')),
                      const SizedBox(height: 4),
                      const Text('[INFO] Replicating SHA-256 DAG commit tree (GranthikSom/CodeHub) @ 450 MB/s', style: TextStyle(color: Color(0xFFC7F0BD), fontSize: 13, fontFamily: 'monospace')),
                      const SizedBox(height: 4),
                      const Text('[SUCCESS] Swarm replica synchronized successfully! Peer ready.', style: TextStyle(color: Color(0xFF86D6A3), fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Footer (Deep Cream Background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: sectionBg,
              child: const Center(
                child: Text(
                  'CodeHub Sovereign P2P Platform • Powered by Rust Engine & libp2p Architecture',
                  style: TextStyle(color: sageGreyText, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, Color iconColor, Color textColor, Color labelColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
      ],
    );
  }

  Widget _buildStepDot(bool isActive, Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }

  Widget _buildStepLine(double height, Color color) {
    return Container(
      width: 1.5,
      height: height,
      color: color,
    );
  }
}

class GitBranchGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFDCD6CD)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final darkLinePaint = Paint()
      ..color = const Color(0xFF1E3A2B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), linePaint);

    final path1 = Path();
    path1.moveTo(10, 440);
    path1.quadraticBezierTo(10, 380, size.width * 0.5, 360);
    canvas.drawPath(path1, darkLinePaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.5, 100);
    path2.quadraticBezierTo(size.width * 0.85, 120, size.width * 0.85, 260);
    canvas.drawPath(path2, darkLinePaint);

    _drawNodeShape(canvas, Offset(size.width * 0.5, 50), 18, ShapeType.diamond, const Color(0xFF7CE3E6));
    _drawNodeShape(canvas, Offset(size.width * 0.85, 160), 18, ShapeType.circle, const Color(0xFF94C9A9));
    _drawNodeShape(canvas, Offset(size.width * 0.5, 160), 18, ShapeType.square, const Color(0xFFFDF0D5));
    _drawNodeShape(canvas, Offset(size.width * 0.85, 230), 18, ShapeType.circle, const Color(0xFF94C9A9));
    _drawNodeShape(canvas, Offset(size.width * 0.5, 230), 18, ShapeType.diamond, const Color(0xFF7CE3E6));
    _drawNodeShape(canvas, Offset(size.width * 0.25, 340), 18, ShapeType.triangle, const Color(0xFF52796F));
    _drawNodeShape(canvas, Offset(size.width * 0.5, 340), 18, ShapeType.square, const Color(0xFFFDF0D5));
    _drawNodeShape(canvas, Offset(size.width * 0.25, 400), 18, ShapeType.triangle, const Color(0xFF52796F));
  }

  void _drawNodeShape(Canvas canvas, Offset center, double size, ShapeType type, Color color) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF19241E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    switch (type) {
      case ShapeType.circle:
        canvas.drawCircle(center, size / 2, fillPaint);
        canvas.drawCircle(center, size / 2, strokePaint);
        break;
      case ShapeType.square:
        final rect = Rect.fromCenter(center: center, width: size, height: size);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), fillPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), strokePaint);
        break;
      case ShapeType.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - size / 1.4)
          ..lineTo(center.dx + size / 1.4, center.dy)
          ..lineTo(center.dx, center.dy + size / 1.4)
          ..lineTo(center.dx - size / 1.4, center.dy)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - size / 1.4)
          ..lineTo(center.dx + size / 1.4, center.dy + size / 1.4)
          ..lineTo(center.dx - size / 1.4, center.dy + size / 1.4)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum ShapeType { circle, square, diamond, triangle }
