import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_classic_bluetooth/flutter_classic_bluetooth.dart';

import '../core/theme/app_theme.dart';
import '../models/game_config.dart';
import '../screens/game_screen.dart';
import '../services/bluetooth_game_session.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';

class BluetoothLobbyScreen extends StatefulWidget {
  const BluetoothLobbyScreen({super.key});

  @override
  State<BluetoothLobbyScreen> createState() => _BluetoothLobbyScreenState();
}

class _BluetoothLobbyScreenState extends State<BluetoothLobbyScreen> {
  final _bluetooth = FlutterClassicBluetooth();
  BtcServerSocket? _server;
  StreamSubscription<BtcConnection>? _serverSubscription;
  List<BtcDevice> _devices = const [];
  int _boardSize = 5;
  int _winLength = 4;
  bool _loading = true;
  bool _scanning = false;
  bool _working = false;
  bool _handedOff = false;
  bool _acceptingConnection = false;
  String? _error;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await SettingsService.loadSettings();
      if (!mounted) return;
      setState(() {
        _boardSize = settings.boardSize;
        _winLength = settings.winLength;
        _loading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load Bluetooth game defaults: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không thể tải cài đặt bàn cờ.';
      });
    }
  }

  Future<bool> _prepareBluetooth(Set<BtcPermission> permissions) async {
    if (!await _bluetooth.isSupported()) {
      _showError('Thiết bị này không hỗ trợ Bluetooth.');
      return false;
    }
    var permissionStatus = await _bluetooth.checkPermissions(
      permissions: permissions,
    );
    if (permissionStatus == BtcPermissionStatus.denied) {
      permissionStatus = await _bluetooth.requestPermissions(
        permissions: permissions,
      );
    }
    if (permissionStatus == BtcPermissionStatus.permanentlyDenied) {
      _showError(
        'Quyền Bluetooth đã bị từ chối. Hãy bật quyền trong cài đặt ứng dụng.',
        action: SnackBarAction(
          label: 'Mở cài đặt',
          onPressed: _bluetooth.openAppSettings,
        ),
      );
      return false;
    }
    if (permissionStatus != BtcPermissionStatus.granted &&
        permissionStatus != BtcPermissionStatus.notRequired) {
      _showError('Cần cấp quyền Bluetooth để tiếp tục.');
      return false;
    }
    if (!await _bluetooth.isEnabled()) {
      final enabled = await _bluetooth.enableBluetooth();
      if (!enabled || !await _bluetooth.isEnabled()) {
        _showError('Hãy bật Bluetooth rồi thử lại.');
        return false;
      }
    }
    return true;
  }

  Future<void> _startHosting() async {
    if (_working) return;
    setState(() {
      _working = true;
      _error = null;
      _status = 'Đang mở phòng Bluetooth...';
    });
    try {
      final ready = await _prepareBluetooth({
        BtcPermission.connect,
        BtcPermission.advertise,
      });
      if (!ready) {
        if (mounted) {
          setState(() {
            _working = false;
            _status = null;
          });
        }
        return;
      }
      if (!mounted) return;
      final capabilities = await _bluetooth.getPlatformCapabilities();
      if (!capabilities.canCreateServer || !capabilities.canSetDiscoverable) {
        throw StateError('Thiết bị không hỗ trợ tạo phòng Bluetooth.');
      }
      final server = await _bluetooth.startServer(
        serviceName: BluetoothGameSession.serviceName,
        uuid: BluetoothGameSession.serviceUuid,
      );
      _server = server;
      _serverSubscription = server.connections.listen(
        _acceptConnection,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Bluetooth server error: $error\n$stackTrace');
          _showError('Không thể nhận kết nối Bluetooth: $error');
        },
      );
      if (!await _bluetooth.setDiscoverable(300)) {
        await _stopServer();
        throw StateError('Chưa bật chế độ hiển thị thiết bị.');
      }
      if (!mounted) return;
      setState(() {
        _working = false;
        _status = 'Đang chờ người chơi khác kết nối...';
      });
    } catch (error, stackTrace) {
      debugPrint('Could not host Bluetooth game: $error\n$stackTrace');
      if (mounted) {
        setState(() {
          _working = false;
          _status = null;
          _error = 'Không thể tạo phòng Bluetooth: $error';
        });
      }
      await _stopServer();
    }
  }

  Future<void> _acceptConnection(BtcConnection connection) async {
    if (_acceptingConnection || _handedOff || !mounted) {
      await connection.close();
      connection.dispose();
      return;
    }
    _acceptingConnection = true;
    setState(() {
      _working = true;
      _status = 'Đã kết nối — đang đồng bộ ván đấu...';
    });
    final config = GameConfig(
      boardSize: _boardSize,
      winLength: _winLength,
      mode: GameMode.bluetooth,
    );
    final session = BluetoothGameSession(
      connection: connection,
      localPlayer: Player.x,
    );
    try {
      await _stopServer();
      await session.sendStart(config);
      if (!mounted) {
        await session.close();
        return;
      }
      _handedOff = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => GameScreen(config: config, bluetoothSession: session),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Could not start Bluetooth game: $error\n$stackTrace');
      await session.close();
      if (mounted) {
        setState(() {
          _working = false;
          _status = null;
          _error = 'Không thể bắt đầu ván Bluetooth: $error';
        });
      }
      _acceptingConnection = false;
    }
  }

  Future<void> _scanDevices() async {
    if (_working || _scanning) return;
    setState(() {
      _scanning = true;
      _error = null;
      _status = 'Đang tìm thiết bị ở gần...';
    });
    try {
      final ready = await _prepareBluetooth({
        BtcPermission.scan,
        BtcPermission.connect,
      });
      if (!ready) {
        if (mounted) {
          setState(() {
            _scanning = false;
            _status = null;
          });
        }
        return;
      }
      if (!mounted) return;
      final paired = await _bluetooth.getPairedDevices();
      if (mounted) setState(() => _devices = paired);
      final discovered = await _bluetooth.scan(
        timeout: const Duration(seconds: 10),
      );
      if (!mounted) return;
      final allDevices = <String, BtcDevice>{};
      for (final device in paired) {
        if (device.type != BtcDeviceType.le) {
          allDevices[device.address] = device;
        }
      }
      for (final device in discovered) {
        if (device.type == BtcDeviceType.le) continue;
        allDevices[device.address] =
            allDevices[device.address]?.mergedWith(device) ?? device;
      }
      setState(() {
        _devices = allDevices.values.toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));
        _scanning = false;
        _status = _devices.isEmpty
            ? 'Chưa thấy thiết bị. Hãy bật chế độ hiển thị trên máy chủ.'
            : 'Chọn thiết bị để kết nối.';
      });
    } catch (error, stackTrace) {
      debugPrint('Bluetooth discovery failed: $error\n$stackTrace');
      if (mounted) {
        setState(() {
          _scanning = false;
          _status = null;
          _error =
              'Không thể tìm thiết bị. Trên Android 11 trở xuống, hãy bật cả dịch vụ vị trí.';
        });
      }
    }
  }

  Future<void> _connectTo(BtcDevice device) async {
    if (_working) return;
    setState(() {
      _working = true;
      _error = null;
      _status = 'Đang ghép đôi với ${device.displayName}...';
    });
    BluetoothGameSession? session;
    try {
      final ready = await _prepareBluetooth({BtcPermission.connect});
      if (!ready) {
        if (mounted) {
          setState(() {
            _working = false;
            _status = null;
          });
        }
        return;
      }
      if (!mounted) return;
      if (device.bondState != BtcBondState.bonded) {
        final paired = await _bluetooth.bondDevice(device.address);
        if (!paired) {
          throw StateError('Ghép đôi Bluetooth đã bị hủy.');
        }
      }
      if (!mounted) return;
      setState(() => _status = 'Đang kết nối đến ${device.displayName}...');
      final connection = await _bluetooth.connect(
        address: device.address,
        uuid: BluetoothGameSession.serviceUuid,
        timeout: const Duration(seconds: 15),
      );
      session = BluetoothGameSession(
        connection: connection,
        localPlayer: Player.o,
      );
      final start = await session.waitForStart();
      final boardSize = start['boardSize'];
      final winLength = start['winLength'];
      if (boardSize is! int ||
          winLength is! int ||
          boardSize < 3 ||
          boardSize > 30 ||
          winLength < 3 ||
          winLength > boardSize) {
        throw const FormatException('Cấu hình bàn cờ nhận được không hợp lệ.');
      }
      if (!mounted) {
        await session.close();
        return;
      }
      _handedOff = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => GameScreen(
            config: GameConfig(
              boardSize: boardSize,
              winLength: winLength,
              mode: GameMode.bluetooth,
            ),
            bluetoothSession: session,
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Bluetooth connection failed: $error\n$stackTrace');
      await session?.close();
      if (mounted) {
        setState(() {
          _working = false;
          _status = null;
          _error = 'Kết nối thất bại: $error';
        });
      }
    }
  }

  Future<void> _stopServer() async {
    await _serverSubscription?.cancel();
    _serverSubscription = null;
    final server = _server;
    _server = null;
    await server?.close();
  }

  void _showError(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), action: action));
  }

  @override
  void dispose() {
    unawaited(_stopServer());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winOptions = List<int>.generate(_boardSize - 2, (i) => i + 3);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Đấu qua Bluetooth',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  const EyebrowLabel('NEARBY · NO INTERNET'),
                  const SizedBox(height: 8),
                  Text(
                    'Đấu trực tiếp\ntrong tầm gần.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kết nối Bluetooth Classic bảo mật. Một máy tạo phòng, máy còn lại ghép đôi và tham gia.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 18),
                  SurfacePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EyebrowLabel('CẤU HÌNH VÁN'),
                        const SizedBox(height: 13),
                        DropdownButtonFormField<int>(
                          initialValue: _boardSize,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Kích thước bàn',
                          ),
                          items: [
                            for (var size = 3; size <= 30; size++)
                              DropdownMenuItem(
                                value: size,
                                child: Text('$size × $size'),
                              ),
                          ],
                          onChanged: _working
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _boardSize = value;
                                    _winLength = _winLength
                                        .clamp(3, value)
                                        .toInt();
                                  });
                                },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _winLength,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Số quân liên tiếp để thắng',
                          ),
                          items: [
                            for (final length in winOptions)
                              DropdownMenuItem(
                                value: length,
                                child: Text('$length quân'),
                              ),
                          ],
                          onChanged: _working
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _winLength = value);
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryActionButton(
                    label: _working && _status?.contains('phòng') == true
                        ? 'Đang tạo phòng...'
                        : 'Tạo phòng · chơi quân X',
                    icon: Icons.wifi_tethering_rounded,
                    onPressed: _working ? () {} : _startHosting,
                  ),
                  const SizedBox(height: 10),
                  SecondaryActionButton(
                    label: _scanning
                        ? 'Đang quét thiết bị...'
                        : 'Tìm và tham gia phòng',
                    icon: Icons.bluetooth_searching_rounded,
                    onPressed: _working || _scanning ? () {} : _scanDevices,
                  ),
                  if (_status != null) ...[
                    const SizedBox(height: 15),
                    SurfacePanel(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          if (_working || _scanning)
                            const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(
                              Icons.bluetooth_connected_rounded,
                              color: AppColors.accent,
                            ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_status!)),
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_devices.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const EyebrowLabel('THIẾT BỊ Ở GẦN'),
                    const SizedBox(height: 9),
                    for (final device in _devices)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SurfacePanel(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            leading: const Icon(
                              Icons.bluetooth_rounded,
                              color: AppColors.accent,
                            ),
                            title: Text(device.displayName),
                            subtitle: Text(
                              device.bondState == BtcBondState.bonded
                                  ? 'Đã ghép đôi · ${device.address}'
                                  : 'Chưa ghép đôi · ${device.address}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: _working ? null : () => _connectTo(device),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 17),
                  const Text(
                    'Mẹo: ghép đôi hai điện thoại trong cài đặt Bluetooth trước nếu thiết bị không xuất hiện khi quét. Máy tạo phòng cần chấp nhận hộp thoại hiển thị thiết bị.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
