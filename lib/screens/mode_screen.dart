import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/game_config.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';
import 'game_screen.dart';

class ModeScreen extends StatefulWidget {
  final GameMode initialMode;
  const ModeScreen({super.key, required this.initialMode});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  static const _presets = <String>['3', '5', '15', '20', 'custom'];
  late final TextEditingController _customSizeController;
  String _preset = '5';
  int _boardSize = 5;
  int _winLength = 4;
  AiDifficulty _difficulty = AiDifficulty.medium;
  bool _loading = true;
  bool _starting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _customSizeController = TextEditingController(text: '10');
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final defaults = await SettingsService.loadSettings();
      if (!mounted) return;
      setState(() {
        _boardSize = defaults.boardSize;
        _preset = _presets.contains(defaults.boardSize.toString())
            ? defaults.boardSize.toString()
            : 'custom';
        _customSizeController.text = defaults.boardSize.toString();
        _winLength = defaults.winLength.clamp(3, defaults.boardSize).toInt();
        _difficulty = defaults.difficulty;
        _loading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load game defaults: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Không thể tải cài đặt đã lưu.';
      });
    }
  }

  void _selectPreset(String? value) {
    if (value == null) return;
    setState(() {
      _preset = value;
      if (value != 'custom') {
        _boardSize = int.parse(value);
        _customSizeController.text = value;
        _winLength = defaultWinLength(_boardSize);
      } else {
        final parsed = int.tryParse(_customSizeController.text);
        if (parsed != null && parsed >= 3 && parsed <= 30) {
          _boardSize = parsed;
          _winLength = defaultWinLength(parsed);
        }
      }
    });
  }

  void _updateCustomSize(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 3 || parsed > 30) return;
    setState(() {
      _boardSize = parsed;
      _winLength = _winLength.clamp(3, parsed).toInt();
    });
  }

  Future<void> _startGame() async {
    if (_starting) return;
    final size = _preset == 'custom'
        ? int.tryParse(_customSizeController.text)
        : int.tryParse(_preset);
    if (size == null || size < 3 || size > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kích thước bàn tùy chỉnh phải từ 3 đến 30.'),
        ),
      );
      return;
    }
    if (_winLength < 3 || _winLength > size) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số quân liên tiếp để thắng không hợp lệ.'),
        ),
      );
      return;
    }

    setState(() => _starting = true);
    final config = GameConfig(
      boardSize: size,
      winLength: _winLength,
      mode: widget.initialMode,
      difficulty: _difficulty,
    );
    try {
      await SettingsService.saveSettings(
        boardSize: size,
        winLength: _winLength,
        difficulty: _difficulty,
      );
    } catch (error, stackTrace) {
      debugPrint('Could not save game defaults: $error\n$stackTrace');
      if (!mounted) return;
      setState(() => _starting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu cài đặt trước khi bắt đầu ván.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _starting = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => GameScreen(config: config)),
    );
  }

  @override
  void dispose() {
    _customSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVsAi = widget.initialMode == GameMode.vsAI;
    final winOptions = List<int>.generate(_boardSize - 2, (index) => index + 3);
    if (!winOptions.contains(_winLength)) {
      _winLength = defaultWinLength(_boardSize);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Thiết lập ván chơi',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadDefaults,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
                children: [
                  const EyebrowLabel('READY PLAYER ONE'),
                  const SizedBox(height: 8),
                  Text(
                    isVsAi ? 'Đối đầu với AI' : 'Cùng nhau so tài',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVsAi
                        ? 'Chọn bàn cờ và độ khó phù hợp với bạn.'
                        : 'Hai người luân phiên đánh X và O trên cùng thiết bị.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 22),
                  SurfacePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldHeading(
                          icon: Icons.grid_4x4_rounded,
                          title: 'Kích thước bàn cờ',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _preset,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Chọn bàn cờ',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '3',
                              child: Text('3 × 3  ·  Tic-tac-toe'),
                            ),
                            DropdownMenuItem(
                              value: '5',
                              child: Text('5 × 5  ·  Nhanh'),
                            ),
                            DropdownMenuItem(
                              value: '15',
                              child: Text('15 × 15  ·  Caro'),
                            ),
                            DropdownMenuItem(
                              value: '20',
                              child: Text('20 × 20  ·  Chiến thuật'),
                            ),
                            DropdownMenuItem(
                              value: 'custom',
                              child: Text('Tùy chỉnh  ·  3 đến 30'),
                            ),
                          ],
                          onChanged: _selectPreset,
                        ),
                        if (_preset == 'custom') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customSizeController,
                            keyboardType: TextInputType.number,
                            onChanged: _updateCustomSize,
                            decoration: const InputDecoration(
                              labelText: 'Kích thước mỗi cạnh',
                              hintText: 'Ví dụ: 10',
                              helperText:
                                  'Nhập số từ 3 đến 30 để tạo bàn vuông.',
                              prefixIcon: Icon(Icons.straighten_rounded),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        const _FieldHeading(
                          icon: Icons.flag_outlined,
                          title: 'Điều kiện chiến thắng',
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _winLength,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Số quân liên tiếp',
                          ),
                          items: winOptions
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value quân liên tiếp'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => value == null
                              ? null
                              : setState(() => _winLength = value),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'Mặc định: bàn 3×3 cần 3 quân, bàn 5×5 cần 4 quân, các bàn lớn cần 5 quân.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  if (isVsAi) ...[
                    const SizedBox(height: 16),
                    SurfacePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldHeading(
                            icon: Icons.psychology_alt_rounded,
                            title: 'Độ khó AI',
                          ),
                          const SizedBox(height: 12),
                          ...AiDifficulty.values.map((difficulty) {
                            final selected = difficulty == _difficulty;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: selected
                                    ? AppColors.accent.withValues(alpha: 0.09)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(15),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () =>
                                      setState(() => _difficulty = difficulty),
                                  child: Container(
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.accent.withValues(
                                                alpha: 0.65,
                                              )
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          difficulty == AiDifficulty.easy
                                              ? Icons.spa_outlined
                                              : difficulty ==
                                                    AiDifficulty.medium
                                              ? Icons.bolt_rounded
                                              : Icons
                                                    .local_fire_department_outlined,
                                          color: selected
                                              ? AppColors.accent
                                              : AppColors.muted,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                difficulty.title,
                                                style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                difficulty.description,
                                                style: const TextStyle(
                                                  color: AppColors.muted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.accent,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  PrimaryActionButton(
                    label: _starting ? 'Đang chuẩn bị...' : 'Bắt đầu ván chơi',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _starting ? () {} : _startGame,
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'X đi trước · Kết quả được lưu trên thiết bị',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FieldHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  const _FieldHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
