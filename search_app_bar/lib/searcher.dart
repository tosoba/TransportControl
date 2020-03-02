import 'dart:core';

abstract class Searcher<T> {
  Function(String) get filterChanged;
  List<T> get data;
}
