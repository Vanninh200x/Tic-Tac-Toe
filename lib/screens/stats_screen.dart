import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/game_stats.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<GameStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = SettingsService.loadStats();
  }

  Future<void> _resetStats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thống kê?'),
        content: const Text(
          'Toàn bộ số trận thắng, thua và hòa đã lưu sẽ được đặt về 0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Giữ lại'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa thống kê'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await SettingsService.clearStats();
    } catch (error, stackTrace) {
      debugPrint('Could not clear saved statistics: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa thống kê đã lưu.')),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() => _statsFuture = SettingsService.loadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Thống kê',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Xóa thống kê',
            onPressed: _resetStats,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: FutureBuilder<GameStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Không thể tải thống kê đã lưu.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(
                          () => _statsFuture = SettingsService.loadStats(),
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          final stats = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
            children: [
              const EyebrowLabel('YOUR PROGRESS'),
              const SizedBox(height: 8),
              Text(
                'Mỗi ván đều có ý nghĩa',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Thành tích được cập nhật khi một ván đấu kết thúc.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF172E65), Color(0xFF211743)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TỔNG SỐ VÁN HOÀN THÀNH',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.totalGames}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tiếp tục chơi để tạo nên thành tích của bạn.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const EyebrowLabel('ĐẤU VỚI AI'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Thắng',
                      value: stats.aiWins,
                      color: AppColors.success,
                      icon: Icons.emoji_events_outlined,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _StatCard(
                      label: 'Thua',
                      value: stats.aiLosses,
                      color: AppColors.coral,
                      icon: Icons.trending_down_rounded,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _StatCard(
                      label: 'Hòa',
                      value: stats.aiDraws,
                      color: AppColors.gold,
                      icon: Icons.handshake_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const EyebrowLabel('HAI NGƯỜI CHƠI'),
              const SizedBox(height: 10),
              SurfacePanel(
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Số ván X thắng',
                      value: stats.playerXWins,
                      symbol: 'X',
                      color: AppColors.accent,
                    ),
                    const Divider(height: 22),
                    _StatRow(
                      label: 'Số ván O thắng',
                      value: stats.playerOWins,
                      symbol: 'O',
                      color: AppColors.coral,
                    ),
                    const Divider(height: 22),
                    _StatRow(
                      label: 'Số ván hòa',
                      value: stats.twoPlayerDraws,
                      symbol: '—',
                      color: AppColors.gold,
                    ),
                    const Divider(height: 22),
                    _StatRow(
                      label: 'Tổng ván hai người',
                      value: stats.twoPlayerGames,
                      symbol: 'Σ',
                      color: AppColors.text,
                    ),
                  ],
                ),
              ),
              if (stats.totalGames == 0) ...[
                const SizedBox(height: 22),
                const Center(
                  child: Text(
                    'Chưa có dữ liệu. Bắt đầu một ván để ghi nhận thành tích đầu tiên!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.5),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final String symbol;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.symbol,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            symbol,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
