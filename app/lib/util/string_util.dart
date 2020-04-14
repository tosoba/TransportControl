final lettersOnlyRegex = RegExp('^[a-zA-Z].*');

extension StringExt on String {
  bool get firstCharIsLetter => this != null && lettersOnlyRegex.hasMatch(this);
}

class Strings {
  static const lines = 'Lines';
  static const locations = 'Locations';
  static const transportControl = 'Transport Control';
  static const transportNearby = 'Transport nearby...';
  static const trackAll = 'Track all';
  static const untrackAll = 'Untrack all';
  static const saveAll = 'Save all';
  static const removeAll = 'Remove all';
}
