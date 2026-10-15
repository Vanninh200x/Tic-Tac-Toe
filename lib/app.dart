import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'widgets/space_backdrop.dart';

class BoardGameApp extends StatelessWidget {
  const BoardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boardly — Board Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [const SpaceBackdrop(), ?child],
      ),
      home: const HomeScreen(),
    );
  }
}
