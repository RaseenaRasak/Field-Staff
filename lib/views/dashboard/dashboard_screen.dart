import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../auth/login_screen.dart';
import '../attendance/mark_attendance_screen.dart';
import '../leave/apply_leave_screen.dart';
import '../leave/leave_list_screen.dart';
import '../route/route_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load attendance status when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendanceStatus();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attendance = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${auth.user?.firstName ?? 'User'} 👋',
                              style: const TextStyle(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Text('Field Staff', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Text(
                                (auth.user?.firstName.isNotEmpty == true)
                                    ? auth.user!.firstName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: _logout,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Attendance status card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: attendance.isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statusItem(
                                  'Mark In',
                                  attendance.attendance?.markInTime ?? '--:--',
                                  Icons.login,
                                ),
                                Container(width: 1, height: 40, color: Colors.white30),
                                _statusItem(
                                  'Mark Out',
                                  attendance.attendance?.markOutTime ?? '--:--',
                                  Icons.logout,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 16),

                    // Action grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _actionCard(
                          'Mark Attendance',
                          Icons.fingerprint,
                          AppColors.primary,
                          () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const MarkAttendanceScreen())),
                        ),
                        _actionCard(
                          'Apply Leave',
                          Icons.event_busy,
                          Colors.orange,
                          () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ApplyLeaveScreen())),
                        ),
                        _actionCard(
                          'Leave List',
                          Icons.list_alt,
                          Colors.blue,
                          () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const LeaveListScreen())),
                        ),
                        _actionCard(
                          'My Route',
                          Icons.map,
                          Colors.green,
                          () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RouteListScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusItem(String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}