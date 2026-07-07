class Validators {
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (10-15 digits)';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 0) {
      return 'Number must be positive';
    }
    return null;
  }

  static String? validateSteps(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter steps';
    }
    final steps = int.tryParse(value);
    if (steps == null) {
      return 'Please enter a valid number';
    }
    if (steps < 0) {
      return 'Steps cannot be negative';
    }
    if (steps > 100000) {
      return 'Steps seem too high (max 100,000)';
    }
    return null;
  }

  static String? validateCalories(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter calories';
    }
    final calories = int.tryParse(value);
    if (calories == null) {
      return 'Please enter a valid number';
    }
    if (calories < 0) {
      return 'Calories cannot be negative';
    }
    if (calories > 10000) {
      return 'Calories seem too high (max 10,000)';
    }
    return null;
  }

  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter duration';
    }
    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Please enter a valid number';
    }
    if (duration < 1) {
      return 'Duration must be at least 1 minute';
    }
    if (duration > 480) {
      return 'Duration seems too high (max 8 hours)';
    }
    return null;
  }

  static String? validateDate(String? value, {bool futureAllowed = true}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a date';
    }
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      if (!futureAllowed && date.isAfter(now)) {
        return 'Date cannot be in the future';
      }
      if (date.year < 2000 || date.year > 2100) {
        return 'Please enter a valid year (2000-2100)';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/\S*)?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  static String? validateAlphaNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    final alphaNumRegex = RegExp(r'^[a-zA-Z0-9_\- ]+$');
    if (!alphaNumRegex.hasMatch(value)) {
      return 'Only alphanumeric characters, spaces, underscores, and hyphens are allowed';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
}
