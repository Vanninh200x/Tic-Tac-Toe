import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'providers/settings_controller.dart';
import 'services/storage_service.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dịch vụ lưu trữ cục bộ
  final storageService = StorageService();
  await storageService.init();

  // Khởi tạo Controller cài đặt
  final settingsController = SettingsController(storageService: storageService);

  runApp(TicTacToeApp(settingsController: settingsController));
}

class TicTacToeApp extends StatelessWidget {
  final SettingsController settingsController;

  const TicTacToeApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        final themeCfg = AppTheme.getConfig(settingsController.themeMode);
        final isDark = themeCfg.isDark;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: themeCfg.backgroundColor,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Tic-Tac-Toe & Caro Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeData(settingsController.themeMode),
          home: HomeScreen(settingsController: settingsController),
        );
      },
    );
  }
}
