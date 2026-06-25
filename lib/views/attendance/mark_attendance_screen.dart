import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/attendance_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendanceStatus();
    });
  }

  Future<void> _mark(String status) async {
    final provider = context.read<AttendanceProvider>();
    final success = await provider.markAttendance(status);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? provider.successMessage! : provider.errorMessage!),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) provider.clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (_, attendance, __) {
          if (attendance.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final att = attendance.attendance;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        att == null || att.notMarked
                            ? 'Not Marked Today'
                            : att.isMarkedIn
                                ? 'Marked In'
                                : 'Marked Out',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (att?.markInTime != null) ...[
                        const SizedBox(height: 8),
                        Text('In: ${att!.markInTime}', style: const TextStyle(color: Colors.white70)),
                      ],
                      if (att?.markOutTime != null) ...[
                        const SizedBox(height: 4),
                        Text('Out: ${att!.markOutTime}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Mark In button
                if (att == null || att.notMarked)
                  _markButton('Mark In', Icons.login, AppColors.success, () => _mark('mark_in')),

                // Mark Out button (only if already marked in)
                if (att != null && att.isMarkedIn)
                  _markButton('Mark Out', Icons.logout, AppColors.error, () => _mark('mark_out')),

                // Already marked out message
                if (att != null && att.isMarkedOut)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success),
                        SizedBox(width: 8),
                        Text('Attendance complete for today!',
                            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _markButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}