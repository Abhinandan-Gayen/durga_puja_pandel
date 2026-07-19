class Validators {
  const Validators._();

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'Email');
    if (requiredError != null) {
      return requiredError;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value!.trim()) ? null : 'Enter a valid email';
  }

  static String? password(String? value) {
    final requiredError = required(value, 'Password');
    if (requiredError != null) {
      return requiredError;
    }
    return value!.length >= 6 ? null : 'Password must be at least 6 characters';
  }

  static String? latitude(String? value) {
    final requiredError = required(value, 'Latitude');
    if (requiredError != null) {
      return requiredError;
    }
    final latitude = double.tryParse(value!.trim());
    if (latitude == null || latitude < -90 || latitude > 90) {
      return 'Enter a valid latitude between -90 and 90';
    }
    return null;
  }

  static String? longitude(String? value) {
    final requiredError = required(value, 'Longitude');
    if (requiredError != null) {
      return requiredError;
    }
    final longitude = double.tryParse(value!.trim());
    if (longitude == null || longitude < -180 || longitude > 180) {
      return 'Enter a valid longitude between -180 and 180';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, String fieldName) {
    final requiredError = required(value, fieldName);
    if (requiredError != null) {
      return requiredError;
    }
    final number = double.tryParse(value!.trim());
    if (number == null || number < 0) {
      return '$fieldName must be 0 or greater';
    }
    return null;
  }
}
