import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'first_name': TextEditingController(),
    'last_name': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'address': TextEditingController(),
    'dob': TextEditingController(),
    'mobile_number': TextEditingController(),
    'doj': TextEditingController(),
    'location': TextEditingController(),
  };
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  Future<void> _pickDate(String field) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      _controllers[field]!.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register({
      'first_name': _controllers['first_name']!.text.trim(),
      'last_name': _controllers['last_name']!.text.trim(),
      'email': _controllers['email']!.text.trim(),
      'password': _controllers['password']!.text,
      'address': _controllers['address']!.text.trim(),
      'dob': _controllers['dob']!.text,
      'mobile_number': _controllers['mobile_number']!.text.trim(),
      'doj': _controllers['doj']!.text,
      'location': _controllers['location']!.text.trim(),
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please login.'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registration failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('First Name', 'first_name', Icons.person,
                  validator: (v) => Validators.validateRequired(v, 'First Name')),
              _buildField('Last Name', 'last_name', Icons.person_outline,
                  validator: (v) => Validators.validateRequired(v, 'Last Name')),
              _buildField('Email', 'email', Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail),
              _buildField('Mobile Number', 'mobile_number', Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validateMobile),
              _buildField('Password', 'password', Icons.lock,
                  obscure: true,
                  validator: Validators.validatePassword),
              _buildField('Address', 'address', Icons.home,
                  validator: (v) => Validators.validateRequired(v, 'Address')),
              _buildDateField('Date of Birth', 'dob'),
              _buildDateField('Date of Joining', 'doj'),
              _buildField('Location', 'location', Icons.location_on,
                  validator: (v) => Validators.validateRequired(v, 'Location')),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (_, auth, __) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String key,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType,
        obscureText: obscure ? _obscurePassword : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: obscure
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textGrey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controllers[key],
        readOnly: true,
        onTap: () => _pickDate(key),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        ),
        validator: Validators.validateDate,
      ),
    );
  }
}