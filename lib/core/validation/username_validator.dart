class UsernameValidator {
  UsernameValidator._();

  static final RegExp _usernamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

  static String normalize(String value) {
    return value.trim().toLowerCase();
  }

  static bool isValid(String value) {
    return _usernamePattern.hasMatch(normalize(value));
  }

  static String? validationError(String value) {
    final username = normalize(value);

    if (username.isEmpty) {
      return 'Username is required.';
    }

    if (username.length < 3 || username.length > 20) {
      return 'Username must be 3 to 20 characters.';
    }

    if (!_usernamePattern.hasMatch(username)) {
      return 'Use lowercase letters, numbers, and underscores only.';
    }

    return null;
  }
}
