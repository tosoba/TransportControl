final _lettersOnlyRegex = RegExp('^[a-zA-Z].*');

extension StringExt on String {
  bool get firstCharIsLetter => this != null && _lettersOnlyRegex.hasMatch(this);
}
