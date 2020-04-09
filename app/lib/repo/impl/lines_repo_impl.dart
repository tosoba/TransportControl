import 'package:injectable/injectable.dart';
import 'package:transport_control/db/dao/favourite_lines_dao.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/repo/lines_repo.dart';

@RegisterAs(LinesRepo, env: Env.dev)
@singleton
class LinesRepoImpl extends LinesRepo {
  final FavouriteLinesDao _dao;

  LinesRepoImpl(this._dao);

  @override
  Stream<List<FavouriteLine>> get favouriteLinesStream {
    return _dao.favouriteLinesStream;
  }

  @override
  Future insertLine(FavouriteLine line) {
    return _dao.insertLine(line);
  }

  @override
  Future<void> insertLines(Iterable<FavouriteLine> lines) {
    return _dao.insertLines(lines);
  }
}
