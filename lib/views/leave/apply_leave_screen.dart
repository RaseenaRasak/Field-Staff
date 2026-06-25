import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  String _leaveMode = 'full_day';
  String _leaveType = 'Casual Leave';
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _reasonController = TextEditingController();

  final _leaveTypes = ['Casual Leave', 'Sick Leave', 'Earned Leave', 'Maternity Leave'];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      controller.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _applyLeave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final leaveProvider = context.read<LeaveProvider>();

    final success = await leaveProvider.applyLeave({
      'leave_mode': _leaveMode,
      'leave_type': _leaveType,
      'start_date': _startDateController.text,
      'end_date': _endDateController.text,
      'reason': _reasonController.text.trim(),
      'user_id': auth.user?.id,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? leaveProvider.successMessage! : leaveProvider.errorMessage!),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) {
        leaveProvider.clearMessages();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply Leave'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Mode toggle
              const Text('Leave Mode', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _modeChip('Half Day', 'half_day'),
                  const SizedBox(width: 12),
                  _modeChip('Full Day', 'full_day'),
                ],
              ),
              const SizedBox(height: 20),

              // Leave Type
              const Text('Leave Type', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _leaveType,
                decoration: _inputDec('Select Leave Type', Icons.category),
                items: _leaveTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _leaveType = v!),
                validator: (v) => v == null ? 'Select a leave type' : null,
              ),
              const SizedBox(height: 16),

              // From Date
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                onTap: () => _pickDate(_startDateController),
                decoration: _inputDec('From Date', Icons.calendar_today),
                validator: Validators.validateDate,
              ),
              const SizedBox(height: 16),

              // To Date
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                onTap: () => _pickDate(_endDateController),
                decoration: _inputDec('To Date', Icons.calendar_today),
                validator: Validators.validateDate,
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: _inputDec('Reason', Icons.note),
                validator: (v) => Validators.validateRequired(v, 'Reason'),
              ),
              const SizedBox(height: 24),

              // Submit button
              Consumer<LeaveProvider>(
                builder: (_, leave, __) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: leave.isLoading ? null : _applyLeave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: leave.isLoading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Apply Leave', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeChip(String label, String value) {
    final selected = _leaveMode == value;
    return GestureDetector(
      onTap: () => setState(() => _leaveMode = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textGrey,
            fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
    );
  }
}