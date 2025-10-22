import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AttendanceListItem extends StatelessWidget {
  final String studentName;
  final String studentId;
  final DateTime timestamp;
  final bool bleVerified;
  final bool qrVerified;
  final VoidCallback? onRemove;

  const AttendanceListItem({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.timestamp,
    this.bleVerified = false,
    this.qrVerified = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isFullyVerified = bleVerified && qrVerified;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFullyVerified ? Colors.green : Colors.orange,
          width: isFullyVerified ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFullyVerified
                  ? Colors.green.withAlpha((0.1 * 255).round())
                  : Colors.orange.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.user,
              size: 20,
              color: isFullyVerified ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$studentId • ${DateFormat('hh:mm a').format(timestamp)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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
                  color: isFullyVerified ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFullyVerified ? Icons.check_circle : Icons.pending,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFullyVerified ? 'Verified' : 'Pending',
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bleVerified)
                    const FaIcon(
                      FontAwesomeIcons.bluetooth,
                      size: 10,
                      color: Colors.blue,
                    ),
                  if (bleVerified && qrVerified) const SizedBox(width: 4),
                  if (qrVerified)
                    const FaIcon(
                      FontAwesomeIcons.qrcode,
                      size: 10,
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}
