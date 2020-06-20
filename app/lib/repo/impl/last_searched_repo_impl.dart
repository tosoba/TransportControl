import 'package:injectable/injectable.dart';
import 'package:transport_control/db/dao/last_searched_dao.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/repo/last_searched_repo.dart';

@RegisterAs(LastSearchedRepo, env: Env.dev)
@singleton
class LastSearchedRepoImpl extends LastSearchedRepo {
  final LastSearchedDao _dao;

  LastSearchedRepoImpl(this._dao);

  @override
  Stream<List<SearchedItem>> getLastSearchedItemsStream({int limit}) {
    return _dao
        .selectLatestSearchedItems(
          limit: limit,
        )
        .map(
          (entities) => entities
              .map(
                (entity) => entity.when(
                  lineEntity: (lineEnt) => SearchedItem.lineItem(
                    line: Line.fromDb(lineEnt.line),
                  ),
                  locationEntity: (locationEnt) => SearchedItem.locationItem(
                    location: Location.fromDb(locationEnt.location),
                  ),
                ),
              )
              .toList(),
        );
  }
}
