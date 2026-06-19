import '../constants/app_constants.dart';

class InputValidators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');
  static final RegExp _cardRegex = RegExp(r'^[0-9\s]{16,19}$');
  static final RegExp _cvvRegex = RegExp(r'^[0-9]{3,4}$');
  static final RegExp _amountRegex = RegExp(r'^[0-9]*\.?[0-9]+$');

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Please enter a valid email';
    if (value.contains('..')) return 'Please enter a valid email';
    if (value.startsWith('.') || value.endsWith('.')) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!_phoneRegex.hasMatch(value)) return 'Please enter a valid phone number';
    return null;
  }

  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number is required';
    if (!_cardRegex.hasMatch(value)) return 'Please enter a valid card number';
    return null;
  }

  static String? validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (!_cvvRegex.hasMatch(value)) return 'CVV must be 3 or 4 digits';
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    if (!_amountRegex.hasMatch(value)) return 'Please enter a valid amount';
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) return 'Amount must be greater than zero';
    
    return null;
  }
}