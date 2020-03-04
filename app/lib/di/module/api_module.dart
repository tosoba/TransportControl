import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@registerModule
abstract class ApiModule {
  @singleton
  Dio get client => Dio()..options.headers['Content-Type'] = 'application/json';
}