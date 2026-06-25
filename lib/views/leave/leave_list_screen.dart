import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/leave_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLeaves());
  }

  void _fetchLeaves() {
    final auth = context.read<AuthProvider>();
    context.read<LeaveProvider>().fetchLeaves(
      employeeId: auth.user?.id ?? 0,
      leaveType: _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leave List'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'pending', 'approved', 'rejected']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _filterChip(f),
                        ))
                    .toList(),
              ),
            ),
          ),

          // Leave list
          Expanded(
            child: Consumer<LeaveProvider>(
              builder: (_, leave, __) {
                if (leave.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (leave.leaves.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: AppColors.textGrey),
                        SizedBox(height: 12),
                        Text('No leaves found', style: TextStyle(color: AppColors.textGrey)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: leave.leaves.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _leaveCard(leave.leaves[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filter) {
    final selected = _selectedFilter == filter;
    Color chipColor;
    switch (filter) {
      case 'pending': chipColor = AppColors.pending; break;
      case 'approved': chipColor = AppColors.approved; break;
      case 'rejected': chipColor = AppColors.rejected; break;
      default: chipColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = filter);
        _fetchLeaves();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? chipColor : AppColors.divider),
        ),
        child: Text(
          filter[0].toUpperCase() + filter.substring(1),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textGrey,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _leaveCard(LeaveModel leave) {
    Color statusColor;
    IconData statusIcon;
    switch (leave.status) {
      case 'approved':
        statusColor = AppColors.approved;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.rejected;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.pending;
        statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(leave.leaveType,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      leave.status[0].toUpperCase() + leave.status.substring(1),
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.textGrey),
              const SizedBox(width: 4),
              Text('${leave.startDate} → ${leave.endDate}',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(leave.leaveMode.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ),
            ],
          ),
          if (leave.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(leave.reason,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}