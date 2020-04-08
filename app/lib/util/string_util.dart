final lettersOnlyRegex = RegExp('^[a-zA-Z].*');

extension StringExt on String {
  bool get firstCharIsLetter => this != null && lettersOnlyRegex.hasMatch(this);
}
