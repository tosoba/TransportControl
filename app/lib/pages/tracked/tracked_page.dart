import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
      if (filter != null && filter.isNotEmpty) {
        filterController.add(filter.trim().toLowerCase());
      }
    });

    return StreamBuilder<List<MapEntry<MapVehicleSource, Set<Vehicle>>>>(
      //TODO: combine stream with filterController
      stream: context.bloc<MapBloc>().map((state) {
        final sourcesMap = SplayTreeMap<MapVehicleSource, Set<Vehicle>>(
          (source1, source2) => source2.loadedAt.compareTo(source1.loadedAt),
        );
        state.trackedVehicles.values.forEach((tracked) {
          tracked.sources.forEach((source) {
            sourcesMap.putIfAbsent(source, () => {});
            sourcesMap[source].add(tracked.vehicle);
          });
        });
        return sourcesMap.entries.toList();
      }),
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
              : CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      delegate: SliverTextFieldAppBarDelegate(
                        context,
                        appBar: appBar,
                      ),
                      floating: true,
                    ),
                    _sourcesList(context, sources: sources),
                  ],
                ),
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
        title: Text(source.key.when(
          ofLine: (s) => 'Of line: ${s.line.symbol}',
          nearbyLocation: (s) => 'Nearby ${s.location.name}',
          nearbyPosition: (s) =>
              '''Nearby your location loaded${dateTimeDiffInfo(
            diffMillis: DateTime.now().millisecondsSinceEpoch -
                s.loadedAt.millisecondsSinceEpoch,
            prefix: '',
          )}''',
        )),
        subtitle: Text(
          '${source.value.length.toString()} ${source.value.length > 1 ? 'vehicles' : 'vehicle'} in total',
        ),
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
