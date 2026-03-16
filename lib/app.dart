import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

class MarkviewApp extends ConsumerWidget {
  const MarkviewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'markview',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF0969DA),
      secondary: Color(0xFF0969DA),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1F2328),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FA),
        foregroundColor: Color(0xFF1F2328),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFD0D7DE),
    );
  }

  ThemeData _buildDarkTheme() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF58A6FF),
      secondary: Color(0xFF58A6FF),
      surface: Color(0xFF0D1117),
      onSurface: Color(0xFFE6EDF3),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161B22),
        foregroundColor: Color(0xFFE6EDF3),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      dividerColor: const Color(0xFF30363D),
    );
  }
}
