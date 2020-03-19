import 'package:flutter/material.dart';
import 'package:transport_control/model/result.dart';

extension FutureExt<T, R> on Future<R> {
  Future<Result<T>> thenTransformAndWrapIntoResult({
    @required T Function(R) transform,
  }) {
    return then(
      (value) => Result.success(transform(value)),
      onError: (err) => Result.error(err),
    );
  }
}
