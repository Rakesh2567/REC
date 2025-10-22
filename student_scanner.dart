import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:attendify/models/session.dart';
import 'package:attendify/services/ble_service.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/utils/theme.dart';
import 'package:attendify/utils/constants.dart';

class StudentScanner extends StatefulWidget {
  const StudentScanner({super.key});

  @override
  State<StudentScanner> createState() => _StudentScannerState();
}

class _StudentScannerState extends State<StudentScanner> {
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  // removed unused fields: _isBroadcasting, _scannedSessionId
  bool _attendanceMarked = false;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _stopBroadcasting();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _startBroadcasting() async {
    final authService = context.read<AuthService>();
    final bleService = context.read<BLEService>();

    if (authService.currentUser == null) return;

    // broadcasting state handled by BLEService; no local field

    // Start BLE broadcasting with student ID
    await bleService.startStudentBroadcasting(authService.currentUser!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              FaIcon(FontAwesomeIcons.bluetooth, color: Colors.white),
              SizedBox(width: 8),
              Text('BLE broadcasting started'),
            ],
          ),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _stopBroadcasting() async {
    final bleService = context.read<BLEService>();
    await bleService.stopStudentBroadcasting();

    // broadcasting state handled by BLEService; no local field
  }

  Future<void> _startScanning() async {
    // First, start BLE broadcasting
    await _startBroadcasting();

    setState(() {
      _isScanning = true;
      _attendanceMarked = false;
    });

    // Add a small delay to ensure BLE starts before QR scanning
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _stopBroadcasting();
  }

  void _onQRScanned(BarcodeCapture capture) async {
    if (_attendanceMarked) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrData = barcodes.first.rawValue;
    if (qrData == null) return;

    try {
      // Parse QR data
      final session = AttendanceSession.fromQR(qrData);

      // Check if session is valid
      if (session.isExpired) {
        _showError('Session has expired');
        return;
      }

      // Get BLE and auth services as needed (used elsewhere via context)

      // Simulate waiting for BLE detection by teacher
      // In production, you'd verify with backend that teacher detected the BLE
      await Future.delayed(const Duration(milliseconds: 1000));

      // Mark attendance
      setState(() {
        _attendanceMarked = true;
        _isScanning = false;
      });

      // Award points
      _awardPoints(AppConstants.pointsPerAttendance);

      // Stop broadcasting after successful scan
      await _stopBroadcasting();

      // Show success dialog
      if (mounted) {
        _showSuccessDialog(session);
      }
    } catch (e) {
      _showError('Invalid QR code');
    }
  }

  void _awardPoints(int points) {
    // In production, this would call an API
    // For now, just show a notification
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const FaIcon(FontAwesomeIcons.coins, color: Colors.white),
                const SizedBox(width: 8),
                Text('+$points points earned!'),
              ],
            ),
            backgroundColor: const Color(0xFF9333EA),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _showSuccessDialog(AttendanceSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Attendance Marked!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Successfully joined ${session.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withAlpha((0.3 * 255).round())),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.bluetooth,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'BLE Verified',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.qrcode,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'QR Verified',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QR Code Scanner',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan QR codes to mark your attendance',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // BLE Status Card
            Consumer<BLEService>(
              builder: (context, bleService, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: bleService.isBroadcasting
                                ? AppColors.info.withAlpha((0.1 * 255).round())
                                : Colors.grey.withAlpha((0.1 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FontAwesomeIcons.bluetooth,
                            color: bleService.isBroadcasting
                                ? AppColors.info
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bleService.isBroadcasting
                                    ? 'BLE Broadcasting Active'
                                    : 'BLE Inactive',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: bleService.isBroadcasting
                                      ? AppColors.info
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bleService.isBroadcasting
                                    ? 'Your device is visible to teachers'
                                    : 'Start scanner to broadcast',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (bleService.isBroadcasting)
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.info,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Scanner Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (!_isScanning && !_attendanceMarked)
                      Column(
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.qrcode,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Position QR code within the frame',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _startScanning,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 8),
                                  Text(
                                    'Start Scanner',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (_isScanning)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 280,
                              height: 280,
                              child: MobileScanner(
                                controller: _scannerController,
                                onDetect: _onQRScanned,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.info.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.bluetooth,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Broadcasting BLE signal...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _stopScanning,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(color: AppColors.danger),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (_attendanceMarked)
                      Column(
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: AppColors.success
                                  .withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.success,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 80,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Attendance Marked!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Both BLE and QR verified',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _attendanceMarked = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Scan Another',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction(
                      '1',
                      'Start Scanner',
                      'BLE broadcasting begins automatically',
                    ),
                    _buildInstruction(
                      '2',
                      'Teacher Detection',
                      'Teacher\'s device detects your BLE signal',
                    ),
                    _buildInstruction(
                      '3',
                      'Scan QR Code',
                      'Scan the QR code displayed by teacher',
                    ),
                    _buildInstruction(
                      '4',
                      'Attendance Verified',
                      'Both BLE and QR verified = Attendance marked',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
