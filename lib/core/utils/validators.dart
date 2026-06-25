class Validators {
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value))
      return 'Enter a valid 10 digit mobile number';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Date is required';
    return null;
  }
}