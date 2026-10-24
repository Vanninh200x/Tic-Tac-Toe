import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_controller.dart';
import '../../services/bluetooth_mock_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glossy_button.dart';
import '../widgets/neon_badge.dart';

class BluetoothScreen extends StatefulWidget {
  final SettingsController settingsController;

  const BluetoothScreen({
    super.key,
    required this.settingsController,
  });

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen>
    with SingleTickerProviderStateMixin {
  final BluetoothMockService _bluetoothService = BluetoothMockService();
  List<MockBluetoothDevice> _devices = [];
  bool _isScanning = false;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _startScan();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    _bluetoothService.scanDevices().listen((devicesList) {
      if (mounted) {
        setState(() {
          _devices = List.from(devicesList);
          _isScanning = _bluetoothService.isScanning;
        });
      }
    });
  }

  Future<void> _pairDevice(MockBluetoothDevice device) async {
    setState(() {});
    await _bluetoothService.pairDevice(device);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF162038),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            'Đã kết nối thành công với ${device.name}!',
            style: const TextStyle(
              color: AppColors.cyanNeon,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeCfg = AppTheme.getConfig(widget.settingsController.themeMode);
    final isDark = themeCfg.isDark;

    return Scaffold(
      backgroundColor: themeCfg.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: themeCfg.primaryTextColor,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Đấu Bluetooth',
          style: AppStyles.headingMedium(color: themeCfg.primaryTextColor).copyWith(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Column(
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Đây là giao diện Prototype quét thiết bị và ghép phòng theo tài liệu đặc tả README.',
                        style: AppStyles.bodyMedium(
                          color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                        ).copyWith(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Animated Radar Scanner Visual
              SizedBox(
                height: 190,
                width: 190,
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _RadarPainter(
                        animationValue: _radarController.value,
                        isScanning: _isScanning,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isScanning ? 'Đang quét tìm thiết bị gần...' : 'Đã tìm thấy ${_devices.length} thiết bị',
                style: AppStyles.bodyLarge(color: AppColors.cyanNeon).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Host / Join Room Buttons
              Row(
                children: [
                  Expanded(
                    child: GlossyButton(
                      text: 'TẠO PHÒNG ĐẤU',
                      icon: Icons.add_circle_outline_rounded,
                      gradient: AppColors.xGradient,
                      glowColor: AppColors.cyanNeon,
                      height: 54,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã tạo phòng: "CARO_ROOM_88" (Sẵn sàng chờ đối thủ)'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: themeCfg.primaryTextColor,
                        side: BorderSide(
                          color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 22),
                      label: Text(
                        'Quét Lại',
                        style: AppStyles.bodyMedium(color: themeCfg.primaryTextColor).copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: _startScan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Nearby Devices List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'THIẾT BỊ KHẢ DỤNG',
                    style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const NeonBadge(text: 'BLE 5.0', color: AppColors.cyanNeon),
                ],
              ),
              const SizedBox(height: 14),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _devices.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final dev = _devices[index];
                  return _deviceCard(dev, themeCfg, isDark);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceCard(MockBluetoothDevice device, ThemeConfig themeCfg, bool isDark) {
    final isPaired = device.status == BluetoothDeviceStatus.readyToPlay;
    final isConnecting = device.status == BluetoothDeviceStatus.connecting;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderColor: isPaired ? AppColors.cyanNeon : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cyanNeon.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.phone_android_rounded, color: AppColors.cyanNeon, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${device.macAddress} • ${device.rssi} dBm',
                  style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPaired ? AppColors.success : AppColors.cyanNeon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: isConnecting ? null : () => _pairDevice(device),
            child: isConnecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    isPaired ? 'Sẵn Sàng' : 'Ghép Đôi',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double animationValue;
  final bool isScanning;

  _RadarPainter({required this.animationValue, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Concentric circles
    final circlePaint = Paint()
      ..color = AppColors.cyanNeon.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, maxRadius * 0.33, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.66, circlePaint);
    canvas.drawCircle(center, maxRadius, circlePaint);

    if (isScanning) {
      // Rotating radar sweep
      final sweepAngle = animationValue * 2 * pi;
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0,
          endAngle: 2 * pi,
          colors: [
            AppColors.cyanNeon.withValues(alpha: 0.0),
            AppColors.cyanNeon.withValues(alpha: 0.4),
          ],
          transform: GradientRotation(sweepAngle),
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, maxRadius, sweepPaint);

      // Rotating indicator line
      final linePaint = Paint()
        ..color = AppColors.cyanNeon
        ..strokeWidth = 2.5;
      final lineEnd = Offset(
        center.dx + maxRadius * cos(sweepAngle),
        center.dy + maxRadius * sin(sweepAngle),
      );
      canvas.drawLine(center, lineEnd, linePaint);
    }

    // Center pulse
    final pulsePaint = Paint()
      ..color = AppColors.cyanNeon
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}
