import 'package:flutter/material.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/util/model_util.dart';

class LastSearchedItemsList extends StatelessWidget
    implements PreferredSizeWidget {
  final AsyncSnapshot<SearchedItemsData> itemsDataSnapshot;
  final Animation<double> opacity;
  final void Function(Line) lineItemPressed;
  final void Function(Location) locationItemPressed;
  final void Function() morePressed;
  final bool expanded;

  static const chipHeight = 32.0;
  static const verticalPadding = 10.0;

  const LastSearchedItemsList({
    Key key,
    @required this.itemsDataSnapshot,
    this.opacity,
    this.lineItemPressed,
    this.locationItemPressed,
    @required this.morePressed,
    this.expanded = true,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(chipHeight + verticalPadding);

  @override
  Widget build(BuildContext context) {
    final items = itemsDataSnapshot.data.mostRecentItems;
    final showMoreAvailable = itemsDataSnapshot.data.showMoreAvailable;

    final list = ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 10, top: 5),
      itemCount: showMoreAvailable ? items.length + 1 : items.length,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        return showMoreAvailable && index == items.length
            ? RawChip(
                avatar: const Icon(Icons.more_vert),
                backgroundColor: theme.primaryColor,
                elevation: 5,
                label: const Text('More'),
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                onPressed: morePressed,
              )
            : items.elementAt(index).when(
                  lineItem: (item) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: RawChip(
                      avatar: item.line.type == VehicleType.BUS
                          ? const Icon(Icons.directions_bus)
                          : const Icon(Icons.tram),
                      backgroundColor: theme.primaryColor,
                      elevation: 5,
                      label: Text(item.line.symbol),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 15),
                      onPressed: () => lineItemPressed(item.line),
                    ),
                  ),
                  locationItem: (item) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: RawChip(
                      avatar: const Icon(Icons.location_on),
                      backgroundColor: theme.primaryColor,
                      elevation: 5,
                      label: Text(item.location.name),
                      onPressed: () => locationItemPressed(item.location),
                    ),
                  ),
                );
      },
    );

    final transitionWrapped =
        opacity != null ? FadeTransition(opacity: opacity, child: list) : list;

    return expanded ? Expanded(child: transitionWrapped) : transitionWrapped;
  }
}
