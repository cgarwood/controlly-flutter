import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:controlly/widgets/sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import 'package:controlly/store.dart';

class PageWidget extends StatefulWidget {
  final Map<dynamic, dynamic> pageConfig;
  const PageWidget({Key? key, required this.pageConfig}) : super(key: key);

  @override
  _PageWidgetState createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  @override
  Widget build(BuildContext context) {
    var page = widget.pageConfig;

    var widgets = page['widgets'] ?? [];
    var tileSize = store.userConfig['tileSize'] ?? 128;

    return Stack(
      children: [
        // background image
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          right: 0,
          child: Image.network(
            'https://images.pexels.com/photos/2365457/pexels-photo-2365457.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260',
            fit: BoxFit.cover,
          ),
        ),

        // scrollable widget area
        Positioned(
          left: 24,
          top: 0,
          bottom: 0,
          right: 0,
          child: SingleChildScrollView(
            child: LayoutGrid(
                columnSizes: repeat((page['columns'] ?? 6) * 2, [FixedTrackSize(tileSize / 2)]),
                rowSizes: repeat((page['rows'] ?? 6) * 2, [FixedTrackSize(tileSize / 2)]),
                children: processWidgets(widgets)),
          ),
        ),
      ],
    );
  }

  processWidgets(widgets) {
    return widgets.map<Widget>((value) {
      switch (value['type']) {
        default:
          var entity = store.ha!.entities.firstWhereOrNull((e) => e.id == value['entity_id']);
          if (entity != null) {
            return SensorWidget(entity: entity).withGridPlacement(
                columnStart: ((value['col'] ?? 1) * 2 - 1).abs(),
                rowStart: ((value['row'] ?? 1) * 2 - 1).abs(),
                columnSpan: ((value['width'] ?? 1) * 2).round(),
                rowSpan: ((value['height'] ?? 1) * 2).round());
          }
          return Text('Entity not found: ${value['entity_id']}');
      }
    }).toList();
  }
}
