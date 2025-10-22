import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

class BLEService extends ChangeNotifier {
  // Teacher side - detected students
  final Map<String, BLEDevice> _detectedStudents = {};

  // Student side - broadcasting
  bool _isBroadcasting = false;
  String? _studentBleId;

  // Scanning
  bool _isScanning = false;
  StreamSubscription? _scanSubscription;

  Map<String, BLEDevice> get detectedStudents => _detectedStudents;
  bool get isScanning => _isScanning;
  bool get isBroadcasting => _isBroadcasting;
  String? get studentBleId => _studentBleId;

  // Request BLE permissions
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      return statuses.values.every((status) => status.isGranted);
    }
    return true;
  }

  // Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Error checking Bluetooth state: $e');
      return false;
    }
  }

  // TEACHER SIDE: Start scanning for student devices
  Future<void> startTeacherScanning(String sessionId) async {
    if (_isScanning) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('BLE permissions not granted');
      return;
    }

    final isEnabled = await isBluetoothEnabled();
    if (!isEnabled) {
      debugPrint('Bluetooth is not enabled');
      return;
    }

    _isScanning = true;
    _detectedStudents.clear();
    notifyListeners();

    try {
      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final deviceName = result.device.platformName;

          // Check if device name starts with our prefix
          if (deviceName.startsWith(AppConstants.bleDevicePrefix)) {
            final studentId = deviceName.replaceFirst(
              AppConstants.bleDevicePrefix,
              '',
            );

            // Check RSSI (signal strength) for proximity
            if (result.rssi >= AppConstants.proximityThreshold) {
              _detectedStudents[studentId] = BLEDevice(
                id: studentId,
                name: deviceName,
                rssi: result.rssi,
                sessionId: sessionId,
                lastSeen: DateTime.now(),
              );

              debugPrint(
                '✅ Detected student: $studentId (RSSI: ${result.rssi})',
              );
              notifyListeners();
            }
          }
        }
      });

      // Keep scanning alive with periodic restarts
      Timer.periodic(const Duration(seconds: 6), (timer) {
        if (!_isScanning) {
          timer.cancel();
          return;
        }

        FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 5),
          androidUsesFineLocation: true,
        );
      });
    } catch (e) {
      debugPrint('Error starting scan: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  // TEACHER SIDE: Stop scanning
  Future<void> stopTeacherScanning() async {
    _isScanning = false;
    await _scanSubscription?.cancel();
    await FlutterBluePlus.stopScan();
    _detectedStudents.clear();
    notifyListeners();
    debugPrint('🛑 Stopped teacher scanning');
  }

  // STUDENT SIDE: Start broadcasting BLE ID
  Future<void> startStudentBroadcasting(String studentId) async {
    if (_isBroadcasting) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('BLE permissions not granted');
      return;
    }

    final isEnabled = await isBluetoothEnabled();
    if (!isEnabled) {
      debugPrint('Bluetooth is not enabled');
      return;
    }

    _studentBleId = '${AppConstants.bleDevicePrefix}$studentId';
    _isBroadcasting = true;
    notifyListeners();

    try {
      // Note: Flutter Blue Plus doesn't support advertising directly
      // You'll need to use platform channels for actual BLE advertising
      // This is a placeholder for the concept

      debugPrint('📡 Student broadcasting started: $_studentBleId');

      // For demonstration, we'll simulate broadcasting
      // In production, implement platform-specific advertising
    } catch (e) {
      debugPrint('Error starting broadcast: $e');
      _isBroadcasting = false;
      notifyListeners();
    }
  }

  // STUDENT SIDE: Stop broadcasting
  Future<void> stopStudentBroadcasting() async {
    _isBroadcasting = false;
    _studentBleId = null;
    notifyListeners();
    debugPrint('🛑 Stopped student broadcasting');
  }

  // Check if student BLE ID is detected by teacher
  bool isStudentDetected(String studentId) {
    return _detectedStudents.containsKey(studentId);
  }

  // Get detected student by ID
  BLEDevice? getDetectedStudent(String studentId) {
    return _detectedStudents[studentId];
  }

  // Clean up old detections (remove if not seen in 10 seconds)
  void cleanupOldDetections() {
    final now = DateTime.now();
    _detectedStudents.removeWhere((key, device) {
      return now.difference(device.lastSeen).inSeconds > 10;
    });
    notifyListeners();
  }

  @override
  void dispose() {
    stopTeacherScanning();
    stopStudentBroadcasting();
    _scanSubscription?.cancel();
    super.dispose();
  }
}

class BLEDevice {
  final String id;
  final String name;
  final int rssi;
  final String sessionId;
  final DateTime lastSeen;

  BLEDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.sessionId,
    required this.lastSeen,
  });

  bool get isNearby => rssi >= AppConstants.proximityThreshold;
}
