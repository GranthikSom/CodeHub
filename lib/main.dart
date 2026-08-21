import 'package:flutter/material.dart';
import 'dashboard/landing_page.dart';
import 'services/codehub_state.dart';

void main() {
  runApp(const CodeHubApp());
}

class CodeHubApp extends StatefulWidget {
  const CodeHubApp({super.key});

  @override
  State<CodeHubApp> createState() => _CodeHubAppState();
}

class _CodeHubAppState extends State<CodeHubApp> {
  late final CodeHubState _state;

  @override
  void initState() {
    super.initState();
    _state = CodeHubState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, child) {
        return MaterialApp(
          title: 'CodeHub - P2P Git Platform',
          debugShowCheckedModeBanner: false,
          themeMode: _state.themeMode,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
            primaryColor: const Color(0xFF58A6FF),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF58A6FF),
              secondary: Color(0xFFBC8CFF),
              surface: Color(0xFF161B22),
              error: Color(0xFFF85149),
            ),
            cardColor: const Color(0xFF161B22),
            dividerColor: const Color(0xFF30363D),
            useMaterial3: true,
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue.shade700,
            scaffoldBackgroundColor: const Color(0xFFF6F8FA),
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              secondary: Colors.purple.shade700,
              surface: Colors.white,
            ),
            useMaterial3: true,
          ),
          home: Landingpage(state: _state),
        );
      },
    );
  }
}