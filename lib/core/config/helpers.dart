String? validateEmail(String? value) {
  const emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  } else if (!RegExp(emailRegex).hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}
