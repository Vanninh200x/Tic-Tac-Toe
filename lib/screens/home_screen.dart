import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/game_config.dart';
import '../widgets/common_widgets.dart';
import 'bluetooth_lobby_screen.dart';
import 'mode_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openMode(BuildContext context, GameMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ModeScreen(initialMode: mode)),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _openStats(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const StatsScreen()));
  }

  void _openBluetooth(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BluetoothLobbyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.65),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.19,
                                  ),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.grid_4x4_rounded,
                              color: AppColors.accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BOARDLY',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'NEBULA GAME CLUB',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 8,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _RoundIconButton(
                            tooltip: 'Thống kê',
                            icon: Icons.insights_rounded,
                            onPressed: () => _openStats(context),
                          ),
                          const SizedBox(width: 8),
                          _RoundIconButton(
                            tooltip: 'Cài đặt',
                            icon: Icons.settings_rounded,
                            onPressed: () => _openSettings(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success,
                                  blurRadius: 9,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const EyebrowLabel('YOUR NEXT MOVE'),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Text(
                        'Một nước đi.\nMột chiến thắng.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bước vào vũ trụ chiến thuật — đấu với AI, người ngồi cạnh hoặc kết nối Bluetooth.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 22),
                      _FeaturedGameCard(
                        onPlay: () => _openMode(context, GameMode.vsAI),
                      ),
                      const SizedBox(height: 27),
                      Row(
                        children: [
                          const Expanded(
                            child: EyebrowLabel('CHOOSE YOUR RIVAL'),
                          ),
                          Text(
                            '03 MODES',
                            style: TextStyle(
                              color: AppColors.muted.withValues(alpha: 0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ModeCard(
                        number: '01',
                        icon: Icons.auto_awesome_rounded,
                        color: AppColors.accent,
                        title: 'Đấu với AI',
                        subtitle: 'Ba mức độ — chọn thử thách của bạn',
                        trailing: 'SOLO',
                        onTap: () => _openMode(context, GameMode.vsAI),
                      ),
                      const SizedBox(height: 10),
                      _ModeCard(
                        number: '02',
                        icon: Icons.people_alt_rounded,
                        color: AppColors.gold,
                        title: 'Hai người chơi',
                        subtitle: 'Chuyền tay — một thiết bị, một cuộc đấu',
                        trailing: 'DUO',
                        onTap: () => _openMode(context, GameMode.twoPlayers),
                      ),
                      const SizedBox(height: 10),
                      _ModeCard(
                        number: '03',
                        icon: Icons.bluetooth_rounded,
                        color: AppColors.accent,
                        title: 'Đấu qua Bluetooth',
                        subtitle: 'Kết nối trực tiếp — không cần Internet',
                        trailing: 'NEARBY',
                        onTap: () => _openBluetooth(context),
                      ),
                      const SizedBox(height: 20),
                      _ClubFooter(onStats: () => _openStats(context)),
                      const SizedBox(height: 17),
                      const Center(
                        child: Text(
                          'OFFLINE BY DESIGN  ·  MADE FOR YOUR NEXT MOVE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 8,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.accent,
        fixedSize: const Size(43, 43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.32)),
        ),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

class _FeaturedGameCard extends StatelessWidget {
  final VoidCallback onPlay;

  const _FeaturedGameCard({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.16),
            blurRadius: 22,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Color(0x44000000),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -50,
            child: Container(
              width: 172,
              height: 172,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.09),
                  width: 22,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 18, 19, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ModeTag(label: 'FEATURED MATCH'),
                          SizedBox(height: 14),
                          Text(
                            'Đối đầu\ntrí tuệ.',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 32,
                              height: 0.98,
                              letterSpacing: -1.2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 9),
                          Text(
                            'Máy đã sẵn sàng. Còn bạn?',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _MiniBoardArt(),
                  ],
                ),
                const SizedBox(height: 19),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPlay,
                    icon: const Icon(Icons.bolt_rounded, size: 21),
                    label: const Text('Bắt đầu chơi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.background,
                      shadowColor: AppColors.accent,
                      elevation: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTag extends StatelessWidget {
  final String label;

  const _ModeTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.44)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _MiniBoardArt extends StatelessWidget {
  const _MiniBoardArt();

  @override
  Widget build(BuildContext context) {
    const pieces = <int, String>{0: 'X', 2: 'O', 4: 'O', 6: 'X', 8: 'X'};
    return Transform.rotate(
      angle: -0.055,
      child: Container(
        width: 96,
        height: 96,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color(0xFF080D28),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.18),
              blurRadius: 15,
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final piece = pieces[index];
            final color = piece == 'X' ? AppColors.accent : AppColors.coral;
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141C48),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: piece == null
                  ? null
                  : Text(
                      piece,
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: color.withValues(alpha: 0.65),
                            blurRadius: 9,
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  const _ModeCard({
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(
                number,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: color.withValues(alpha: 0.34)),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trailing,
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(Icons.arrow_outward_rounded, color: color, size: 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClubFooter extends StatelessWidget {
  final VoidCallback onStats;

  const _ClubFooter({required this.onStats});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onStats,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.violet.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.gold,
                size: 23,
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theo dõi hành trình',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Thành tích của bạn, ngay trên máy',
                      style: TextStyle(color: AppColors.muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.violet,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
