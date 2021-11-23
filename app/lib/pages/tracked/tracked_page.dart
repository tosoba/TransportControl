import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class TrackedPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    final filterController = useStreamController<String>();
    searchFieldController.addListener(() {
      final filter = searchFieldController.value.text;
      filterController.add(filter?.trim()?.toLowerCase() ?? filter);
    });

    return StreamBuilder<_FilteredSources>(
      stream:
          context.watch<MapBloc>().sourcesStreamFilteredUsing(filterController),
      builder: (context, snapshot) {
        final filtered = snapshot.data;
        final appBar = TextFieldAppBar(
          textFieldFocusNode: searchFieldFocusNode,
          textFieldController: searchFieldController,
          hint: "Search tracked vehicles...",
          leading: TextFieldAppBarBackButton(searchFieldFocusNode),
          trailing: filtered == null ||
                  filtered.filter == null ||
                  filtered.filter.isEmpty
              ? null
              : CircularButton(
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () {
                    searchFieldController.value = TextEditingValue();
                  },
                ),
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: filtered == null || filtered.sources.isEmpty
              ? Column(children: [
                  appBar,
                  Expanded(
                    child: Center(child: const Text('No tracked vehicles.')),
                  ),
                ])
              : CustomScrollView(slivers: [
                  SliverPersistentHeader(
                    delegate: SliverTextFieldAppBarDelegate(
                      context,
                      appBar: appBar,
                    ),
                    floating: true,
                  ),
                  _sourcesList(context, sources: filtered.sources),
                ]),
          floatingActionButton: _floatingActionButton(
            context,
            sources: filtered?.sources,
          ),
        );
      },
    );
  }

  Widget _sourcesList(
    BuildContext context, {
    @required List<MapEntry<MapVehicleSource, Set<Vehicle>>> sources,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate(
        sources
            .asMap()
            .map(
              (index, source) => MapEntry(
                index,
                AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(
                    child: _sourceListItem(
                      source,
                      context: context,
                      removeSource: context.read<MapBloc>().removeSource,
                    ),
                  ),
                ),
              ),
            )
            .values
            .toList(),
      ),
    );
  }

  Widget _sourceListItem(
    MapEntry<MapVehicleSource, Set<Vehicle>> source, {
    @required BuildContext context,
    @required void Function(MapVehicleSource) removeSource,
  }) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            label: 'Delete',
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (context) {
              removeSource(source.key);
            },
          ),
        ],
      ),
      child: ListTile(
        title: source.key.titleWidget(context),
        subtitle: Text('${source.value.length.toString()} in total'),
      ),
    );
  }

  Widget _floatingActionButton(
    BuildContext context, {
    @required List<MapEntry<MapVehicleSource, Set<Vehicle>>> sources,
  }) {
    if (sources == null || sources.isEmpty) return null;
    return FloatingActionButton.extended(
      onPressed: () => context.read<MapBloc>().clearMap(),
      label: const Text('Clear all'),
    );
  }
}

class _FilteredSources {
  final List<MapEntry<MapVehicleSource, Set<Vehicle>>> sources;
  final String filter;

  _FilteredSources({@required this.sources, @required this.filter});
}

extension _MapBlocExt on MapBloc {
  Stream<_FilteredSources> sourcesStreamFilteredUsing(
    StreamController<String> filterStream,
  ) {
    return stream.map((state) {
      final sourcesMap = Map<MapVehicleSource, Set<Vehicle>>();
      state.mapVehicles.values.forEach((tracked) {
        tracked.sources.forEach((source) {
          sourcesMap.putIfAbsent(source, () => {}).add(tracked.vehicle);
        });
      });
      return sourcesMap.entries.toList()
        ..sort(
          (entry1, entry2) => entry2.key.loadedAt.compareTo(
            entry1.key.loadedAt,
          ),
        );
    }).combineLatest(
      filterStream.stream.startWith(null),
      (sources, String filter) => _FilteredSources(
        sources: filter == null || filter.isEmpty
            ? sources
            : sources
                .where(
                  (entry) => entry.key.title.toLowerCase().contains(filter),
                )
                .toList(),
        filter: filter,
      ),
    );
  }
}

extension _MapVehicleSourceExt on MapVehicleSource {
  String get title {
    return when(
      ofLine: (source) => 'Vehicles of line: ${source.line.symbol}',
      nearbyLocation: (source) =>
          '''Vehicles nearby ${source.location.name} loaded${dateTimeDiffInfo(
        diffMillis: DateTime.now().millisecondsSinceEpoch -
            source.loadedAt.millisecondsSinceEpoch,
        prefix: '',
      )}''',
      nearbyUserLocation: (source) =>
          '''Vehicles nearby your location loaded${dateTimeDiffInfo(
        diffMillis: DateTime.now().millisecondsSinceEpoch -
            source.loadedAt.millisecondsSinceEpoch,
        prefix: '',
      )}''',
      nearbyPlace: (source) =>
          '''Vehicles nearby ${source.title} loaded${dateTimeDiffInfo(
        diffMillis: DateTime.now().millisecondsSinceEpoch -
            source.loadedAt.millisecondsSinceEpoch,
        prefix: '',
      )}''',
    );
  }

  Widget titleWidget(BuildContext context) {
    final titleTextTheme = Theme.of(context).textTheme.subtitle1;
    final normalTextStyle = titleTextTheme.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );
    final boldTextStyle = titleTextTheme.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    return when(
      ofLine: (source) => RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Vehicles of ', style: normalTextStyle),
          TextSpan(text: 'line ${source.line.symbol}', style: boldTextStyle)
        ]),
        overflow: TextOverflow.ellipsis,
      ),
      nearbyLocation: (source) => RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Vehicles nearby ', style: normalTextStyle),
          TextSpan(text: '${source.location.name} ', style: boldTextStyle),
          _loadedAgoTextSpan(source.loadedAt, context),
        ]),
        overflow: TextOverflow.ellipsis,
      ),
      nearbyUserLocation: (source) => RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Vehicles nearby ', style: normalTextStyle),
          TextSpan(text: 'your location ', style: boldTextStyle),
          _loadedAgoTextSpan(source.loadedAt, context),
        ]),
        overflow: TextOverflow.ellipsis,
      ),
      nearbyPlace: (source) => RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Vehicles nearby ', style: normalTextStyle),
          TextSpan(text: '${source.title} ', style: boldTextStyle),
          _loadedAgoTextSpan(source.loadedAt, context),
        ]),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  TextSpan _loadedAgoTextSpan(DateTime loadedAt, BuildContext context) {
    return TextSpan(
      text: '''loaded${dateTimeDiffInfo(
        diffMillis: DateTime.now().millisecondsSinceEpoch -
            loadedAt.millisecondsSinceEpoch,
        prefix: '',
      )}''',
      style: Theme.of(context).textTheme.subtitle1.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
    );
  }
}
