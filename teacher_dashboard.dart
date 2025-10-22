import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:attendify/models/session.dart';
import 'package:attendify/models/attendance_record.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/ble_service.dart';
import 'package:attendify/utils/theme.dart';
import 'package:attendify/widgets/stat_card.dart';
import 'package:attendify/widgets/custom_button.dart';
import 'package:attendify/screens/login/login_page.dart';
import 'teacher_analytics.dart';
import 'teacher_students.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  AttendanceSession? _currentSession;
  Timer? _countdownTimer;
  Timer? _cleanupTimer;
  final List<AttendanceRecord> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    // Capture BLE service once and use in timer callback to avoid using
    // BuildContext across an async gap (timer callback).
    final bleService = context.read<BLEService>();
    // Start cleanup timer for old BLE detections
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Only interact with the service; avoid calling context here.
      bleService.cleanupOldDetections();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cleanupTimer?.cancel();
    context.read<BLEService>().stopTeacherScanning();
    super.dispose();
  }

  void _generateQR() async {
    // Capture services before any await to avoid using BuildContext
    // across async gaps.
    final authService = context.read<AuthService>();
    final bleService = context.read<BLEService>();

    final sessionName = await showDialog<String>(
      context: context,
      builder: (context) => _SessionDialog(),
    );

    if (sessionName == null || sessionName.isEmpty) return;

    // Create session
    final session = AttendanceSession(
      name: sessionName,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      teacherId: authService.currentUser!.id,
    );

    setState(() {
      _currentSession = session;
    });

    // Start BLE scanning for students
    await bleService.startTeacherScanning(session.id);

    // Start countdown
    _startCountdown();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Session started! BLE scanning active.'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession == null || _currentSession!.isExpired) {
        timer.cancel();
        _endSession();
      } else {
        setState(() {});
      }
    });
  }

  void _endSession() {
    context.read<BLEService>().stopTeacherScanning();
    setState(() {
      _currentSession = null;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.qrcode, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Attendify'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Teacher',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = context.read<AuthService>();
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const TeacherAnalytics(),
          const TeacherStudents(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(icon: Icon(Icons.people), label: 'Students'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teacher Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage attendance sessions and monitor student participation',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              StatCard(
                title: 'Present Today',
                value: '24',
                icon: FontAwesomeIcons.userCheck,
                color: AppColors.success,
                backgroundColor: Color(0xFFD1FAE5),
              ),
              StatCard(
                title: 'Absent Today',
                value: '6',
                icon: FontAwesomeIcons.userXmark,
                color: AppColors.danger,
                backgroundColor: Color(0xFFFEE2E2),
              ),
              StatCard(
                title: 'Late Arrivals',
                value: '3',
                icon: FontAwesomeIcons.clock,
                color: AppColors.warning,
                backgroundColor: Color(0xFFFEF3C7),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // QR Generator and Live Attendance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildQRGenerator()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildLiveAttendance()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRGenerator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Session QR',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_currentSession == null)
              CustomButton(
                label: 'Generate QR Code',
                icon: FontAwesomeIcons.qrcode,
                gradient: AppColors.gradientPurple,
                onPressed: _generateQR,
              )
            else ...[
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: _currentSession!.qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentSession!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expires in: ${_formatDuration(_currentSession!.remainingTime)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<BLEService>(
                      builder: (context, bleService, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: bleService.isScanning
                                ? AppColors.success
                                    .withAlpha((0.1 * 255).round())
                                : Colors.grey.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: bleService.isScanning
                                      ? AppColors.success
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bleService.isScanning
                                    ? 'BLE Scanning Active'
                                    : 'BLE Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: bleService.isScanning
                                      ? AppColors.success
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'End Session',
                icon: Icons.stop,
                backgroundColor: AppColors.danger,
                onPressed: _endSession,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAttendance() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Attendance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Consumer<BLEService>(
                  builder: (context, bleService, _) {
                    if (!bleService.isScanning) return const SizedBox();

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Detected Students via BLE
            Consumer<BLEService>(
              builder: (context, bleService, _) {
                final detectedStudents = bleService.detectedStudents;

                if (detectedStudents.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          FontAwesomeIcons.rss,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bleService.isScanning
                              ? 'Scanning for nearby students...'
                              : 'Generate QR to start scanning',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // BLE Detected Students Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.info.withAlpha((0.3 * 255).round()),
                        ),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.bluetooth,
                            size: 16,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${detectedStudents.length} Student(s) Detected via BLE',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List of detected students
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: detectedStudents.length,
                      itemBuilder: (context, index) {
                        final studentId = detectedStudents.keys.elementAt(
                          index,
                        );
                        final device = detectedStudents[studentId]!;

                        // Check if student has also scanned QR
                        final hasScannedQR = _attendanceRecords.any(
                          (record) => record.studentId == studentId,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasScannedQR
                                  ? AppColors.success
                                  : Colors.grey.shade300,
                              width: hasScannedQR ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: hasScannedQR
                                      ? AppColors.success
                                          .withAlpha((0.1 * 255).round())
                                      : AppColors.warning
                                          .withAlpha((0.1 * 255).round()),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  size: 20,
                                  color: hasScannedQR
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Student $studentId',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const FaIcon(
                                          FontAwesomeIcons.bluetooth,
                                          size: 10,
                                          color: AppColors.info,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'RSSI: ${device.rssi} dBm',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasScannedQR
                                          ? AppColors.success
                                          : AppColors.warning,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          hasScannedQR
                                              ? Icons.check_circle
                                              : Icons.pending,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          hasScannedQR
                                              ? 'Verified'
                                              : 'Pending QR',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasScannedQR ? '✓ BLE + QR' : '✓ BLE Only',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Export Button
            if (_attendanceRecords.isNotEmpty)
              CustomButton(
                label: 'Export Attendance',
                icon: Icons.download,
                backgroundColor: AppColors.success,
                onPressed: () {
                  // Export functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exporting attendance data...'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionDialog extends StatefulWidget {
  @override
  State<_SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<_SessionDialog> {
  final _controller = TextEditingController();
  int _duration = 60;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Session Name',
              hintText: 'e.g., Math Class - Period 1',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _duration,
            decoration: const InputDecoration(
              labelText: 'Duration',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 15, child: Text('15 minutes')),
              DropdownMenuItem(value: 30, child: Text('30 minutes')),
              DropdownMenuItem(value: 60, child: Text('60 minutes')),
              DropdownMenuItem(value: 90, child: Text('90 minutes')),
            ],
            onChanged: (value) {
              setState(() {
                _duration = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
