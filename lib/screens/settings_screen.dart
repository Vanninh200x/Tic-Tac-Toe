import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/game_config.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _presets = <String>['3', '5', '15', '20', 'custom'];
  late final TextEditingController _customSizeController;
  String _preset = '5';
  int _boardSize = 5;
  int _winLength = 4;
  AiDifficulty _difficulty = AiDifficulty.medium;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _customSizeController = TextEditingController(text: '10');
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final settings = await SettingsService.loadSettings();
      if (!mounted) return;
      setState(() {
        _boardSize = settings.boardSize;
        _preset = _presets.contains(settings.boardSize.toString())
            ? settings.boardSize.toString()
            : 'custom';
        _customSizeController.text = settings.boardSize.toString();
        _winLength = settings.winLength.clamp(3, settings.boardSize).toInt();
        _difficulty = settings.difficulty;
        _loading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load game settings: $error\n$stackTrace');
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
          _winLength = _winLength.clamp(3, parsed).toInt();
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

  Future<void> _save() async {
    final parsed = _preset == 'custom'
        ? int.tryParse(_customSizeController.text)
        : int.tryParse(_preset);
    if (parsed == null || parsed < 3 || parsed > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kích thước bàn phải từ 3 đến 30.')),
      );
      return;
    }
    if (_winLength < 3 || _winLength > parsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số quân thắng không hợp lệ với bàn cờ.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await SettingsService.saveSettings(
        boardSize: parsed,
        winLength: _winLength,
        difficulty: _difficulty,
      );
    } catch (error, stackTrace) {
      debugPrint('Could not save game settings: $error\n$stackTrace');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu cài đặt. Vui lòng thử lại.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu cài đặt mặc định.')));
  }

  @override
  void dispose() {
    _customSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winOptions = List<int>.generate(_boardSize - 2, (index) => index + 3);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_loadError!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _load,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
              children: [
                const EyebrowLabel('PERSONALIZE YOUR GAME'),
                const SizedBox(height: 8),
                Text(
                  'Theo cách của bạn',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Thiết lập mặc định sẽ được áp dụng cho lần bắt đầu ván tiếp theo.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SettingTitle(
                        icon: Icons.grid_4x4_rounded,
                        title: 'Bàn cờ mặc định',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _preset,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kích thước bàn',
                        ),
                        items: const [
                          DropdownMenuItem(value: '3', child: Text('3 × 3')),
                          DropdownMenuItem(value: '5', child: Text('5 × 5')),
                          DropdownMenuItem(value: '15', child: Text('15 × 15')),
                          DropdownMenuItem(value: '20', child: Text('20 × 20')),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text('Tùy chỉnh · 3 đến 30'),
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
                            helperText: 'Nhập số từ 3 đến 30.',
                            prefixIcon: Icon(Icons.straighten_rounded),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _SettingTitle(
                        icon: Icons.flag_outlined,
                        title: 'Luật thắng',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _winLength.clamp(3, _boardSize).toInt(),
                        decoration: const InputDecoration(
                          labelText: 'Số quân liên tiếp',
                        ),
                        items: winOptions
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value quân'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => value == null
                            ? null
                            : setState(() => _winLength = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SettingTitle(
                        icon: Icons.psychology_alt_rounded,
                        title: 'AI mặc định',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AiDifficulty>(
                        initialValue: _difficulty,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Độ khó'),
                        items: AiDifficulty.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => value == null
                            ? null
                            : setState(() => _difficulty = value),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _difficulty.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryActionButton(
                  label: _saving ? 'Đang lưu...' : 'Lưu cài đặt',
                  icon: Icons.check_rounded,
                  onPressed: _saving ? () {} : _save,
                ),
                const SizedBox(height: 18),
                const SurfacePanel(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline_rounded, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cài đặt và thống kê chỉ được lưu cục bộ trên thiết bị. Game không cần tài khoản hoặc kết nối Internet.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            height: 1.5,
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

class _SettingTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SettingTitle({required this.icon, required this.title});

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
          ),
        ),
      ],
    );
  }
}
