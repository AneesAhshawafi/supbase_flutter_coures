/// Centralised validation logic — single source of truth for all input rules.
class NoteValidators {
  NoteValidators._();

  /// Returns an error string if [value] is not a valid note title, else null.
  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length > 200) return 'Title must be under 200 characters';
    return null;
  }

  /// Returns an error string if [value] is not a valid email, else null.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  /// Returns an error string if [value] is not a valid password, else null.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
