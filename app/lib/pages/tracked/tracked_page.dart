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

    return StreamBuilder<List<MapEntry<MapVehicleSource, Set<Vehicle>>>>(
      stream:
          context.bloc<MapBloc>().sourcesStreamFilteredUsing(filterController),
      builder: (context, snapshot) {
        final sources = snapshot.data;
        final appBar = TextFieldAppBar(
          textFieldFocusNode: searchFieldFocusNode,
          textFieldController: searchFieldController,
          hint: "Search...",
          leading: TextFieldAppBarBackButton(searchFieldFocusNode),
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: sources == null || sources.isEmpty
              ? Column(children: [
                  appBar,
                  Expanded(child: Center(child: Text('No tracked vehicles.'))),
                ])
              : CustomScrollView(slivers: [
                  SliverPersistentHeader(
                    delegate: SliverTextFieldAppBarDelegate(
                      context,
                      appBar: appBar,
                    ),
                    floating: true,
                  ),
                  _sourcesList(context, sources: sources),
                ]),
          floatingActionButton: _floatingActionButton(
            context,
            sources: sources,
          ),
        );
      },
    );
  }

  Widget _sourcesList(
    BuildContext context, {
    @required List<MapEntry<MapVehicleSource, Set<Vehicle>>> sources,
  }) {
    final removeSource = context.bloc<MapBloc>().removeSource;
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
                    child: _sourceListItem(source, removeSource: removeSource),
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
    @required void Function(MapVehicleSource) removeSource,
  }) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        title: source.key.titleWidget,
        subtitle: Text('${source.value.length.toString()} in total'),
      ),
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => removeSource(source.key),
        ),
      ],
    );
  }

  Widget _floatingActionButton(
    BuildContext context, {
    @required List<MapEntry<MapVehicleSource, Set<Vehicle>>> sources,
  }) {
    if (sources == null || sources.isEmpty) return null;
    return FloatingActionButton.extended(
      onPressed: () => context.bloc<MapBloc>().clearMap(),
      label: Text('Clear all'),
    );
  }
}

extension _MapBlocExt on MapBloc {
  Stream<List<MapEntry<MapVehicleSource, Set<Vehicle>>>>
      sourcesStreamFilteredUsing(StreamController<String> filterStream) {
    return map((state) {
      final sourcesMap = Map<MapVehicleSource, Set<Vehicle>>();
      state.trackedVehicles.values.forEach((tracked) {
        tracked.sources.forEach((source) {
          sourcesMap.putIfAbsent(source, () => {}).add(tracked.vehicle);
        });
      });
      return sourcesMap.entries.toList()
        ..sort((entry1, entry2) {
          return entry2.key.loadedAt.compareTo(entry1.key.loadedAt);
        });
    }).combineLatest(
      filterStream.stream.startWith(null),
      (sources, String filter) {
        return filter == null || filter.isEmpty
            ? sources
            : sources
                .where(
                  (entry) => entry.key.title.toLowerCase().contains(filter),
                )
                .toList();
      },
    );
  }
}

extension _MapVehicleSourceExt on MapVehicleSource {
  String get title {
    return when(
      ofLine: (source) => 'Vehicles of line: ${source.line.symbol}',
      nearbyLocation: (source) => 'Vehicles nearby ${source.location.name}',
      nearbyPosition: (source) =>
          '''Vehicles nearby your location loaded${dateTimeDiffInfo(
        diffMillis: DateTime.now().millisecondsSinceEpoch -
            source.loadedAt.millisecondsSinceEpoch,
        prefix: '',
      )}''',
    );
  }

  Widget get titleWidget {
    return when(
      ofLine: (source) => RichText(
        text: TextSpan(children: [
          const TextSpan(
            text: 'Vehicles of ',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          TextSpan(
            text: 'line ${source.line.symbol}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          )
        ]),
        overflow: TextOverflow.ellipsis,
      ),
      nearbyLocation: (source) => RichText(
        text: TextSpan(children: [
          const TextSpan(
            text: 'Vehicles nearby ',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          TextSpan(
            text: '${source.location.name}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          )
        ]),
        overflow: TextOverflow.ellipsis,
      ),
      nearbyPosition: (source) => RichText(
        text: TextSpan(children: [
          const TextSpan(
            text: 'Vehicles nearby ',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          TextSpan(
            text: 'your location',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: '''loaded${dateTimeDiffInfo(
              diffMillis: DateTime.now().millisecondsSinceEpoch -
                  source.loadedAt.millisecondsSinceEpoch,
              prefix: '',
            )}''',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ]),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
