import 'package:collection/collection.dart';
import 'package:controlly/store.dart';
import 'package:controlly/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

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
          left: 0,
          top: 0,
          bottom: 0,
          right: 0,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutGrid(
                  columnSizes: repeat((page['columns'] ?? 8) * 2, [FixedTrackSize(tileSize / 2)]),
                  rowSizes: repeat((page['rows'] ?? 8) * 2, [FixedTrackSize(tileSize / 2)]),
                  children: processWidgets(widgets)),
            ),
          ),
        ),
      ],
    );
  }

  processWidgets(widgets) {
    return widgets.map<Widget>((value) {
      var entity = store.ha!.entities.firstWhereOrNull((e) => e.id == value['entity_id']);
      if (entity != null) {
        var widget = getWidget(value['type'], entity, value);
        var defaults = WIDGET_DEFAULT_SIZES[value['type']];

        var columnStart = ((value['col'] ?? 1) * 2).round();
        var rowStart = ((value['row'] ?? 1) * 2).round();
        var columnSpan = ((value['width'] ?? defaults!['width'] ?? 1) * 2).round();
        var rowSpan = ((value['height'] ?? defaults!['height'] ?? 1) * 2).round();

        return widget.withGridPlacement(
            columnStart: columnStart, rowStart: rowStart, columnSpan: columnSpan, rowSpan: rowSpan);
      }
      return Text('Entity not found: ${value['entity_id']}');
    }).toList();
  }
}
