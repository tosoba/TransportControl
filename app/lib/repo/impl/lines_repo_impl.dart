import 'package:injectable/injectable.dart';
import 'package:transport_control/db/dao/lines_dao.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/repo/lines_repo.dart';

@RegisterAs(LinesRepo, env: Env.dev)
@singleton
class LinesRepoImpl extends LinesRepo {
  final LinesDao _dao;

  LinesRepoImpl(this._dao);

  @override
  Stream<Iterable<Line>> get favouriteLinesStream {
    return _dao.selectFavouriteLinesStream
        .map((dbLines) => dbLines.map((dbLine) => Line.fromDb(dbLine)));
  }

  @override
  Future insertLine(Line line) => _dao.insertLine(line.db);

  @override
  Future<int> deleteLines(Iterable<String> symbols) {
    return _dao.deleteLines(symbols);
  }

  @override
  Future<void> insertLines(Iterable<Line> lines) {
    return _dao.insertLines(lines.map((line) => line.db));
  }

  @override
  Future<int> updateLastSearched(Iterable<String> symbols) {
    return _dao.updateLastSearched(symbols);
  }
}
