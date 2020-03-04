import 'package:sealed_unions/factories/doublet_factory.dart';
import 'package:sealed_unions/implementations/union_2_impl.dart';
import 'package:sealed_unions/union_2.dart';

class Result<T> extends Union2Impl<Success<T>, Error> {
  static Doublet<Success<T>, Error> _factory<T>() =>
      Doublet<Success<T>, Error>();

  Result._(Union2<Success<T>, Error> union) : super(union);

  factory Result.success(T data) =>
      Result._(_factory().first(Success<T>(data)));
  factory Result.error(error) => Result._(_factory().second(Error(error)));
}

class Success<T> {
  final T data;

  Success(this.data);
}

class Error {
  final error;

  Error(this.error);
}
