import 'dart:async';

enum BluetoothDeviceStatus {
  available,
  connecting,
  paired,
  readyToPlay,
}

class MockBluetoothDevice {
  final String id;
  final String name;
  final String macAddress;
  final int rssi; // Signal strength -40 to -90 dBm
  BluetoothDeviceStatus status;

  MockBluetoothDevice({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.rssi,
    this.status = BluetoothDeviceStatus.available,
  });
}

class BluetoothMockService {
  final List<MockBluetoothDevice> _devices = [
    MockBluetoothDevice(
      id: 'dev_1',
      name: 'Samsung Galaxy S24 Ultra',
      macAddress: 'DC:A6:32:8B:11:02',
      rssi: -48,
    ),
    MockBluetoothDevice(
      id: 'dev_2',
      name: 'Google Pixel 9 Pro',
      macAddress: 'F4:0F:24:AA:77:3C',
      rssi: -59,
    ),
    MockBluetoothDevice(
      id: 'dev_3',
      name: 'Xiaomi 14 Pro',
      macAddress: '3C:06:30:12:4D:90',
      rssi: -72,
    ),
    MockBluetoothDevice(
      id: 'dev_4',
      name: 'iPad Pro M2 (Nearby)',
      macAddress: '00:1A:7D:DA:71:15',
      rssi: -81,
    ),
  ];

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Stream<List<MockBluetoothDevice>> scanDevices() async* {
    _isScanning = true;
    yield [];
    await Future.delayed(const Duration(milliseconds: 600));
    yield [_devices[0]];
    await Future.delayed(const Duration(milliseconds: 700));
    yield [_devices[0], _devices[1]];
    await Future.delayed(const Duration(milliseconds: 800));
    yield _devices;
    _isScanning = false;
  }

  Future<bool> pairDevice(MockBluetoothDevice device) async {
    device.status = BluetoothDeviceStatus.connecting;
    await Future.delayed(const Duration(milliseconds: 1200));
    device.status = BluetoothDeviceStatus.paired;
    await Future.delayed(const Duration(milliseconds: 500));
    device.status = BluetoothDeviceStatus.readyToPlay;
    return true;
  }
}
