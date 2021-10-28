import 'package:controlly/homeassistant/entity.dart';
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
            child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widgets.map<Widget>((value) {
                  var entity = store.ha!.entities.firstWhereOrNull((e) => e.id == value['entity_id']);
                  if (entity != null) {
                    return SensorWidget(entity: entity);
                  }
                  return Text('Entity not found: ${value['entity_id']}');
                }).toList()),
          ),
        ),
      ],
    );
  }
}
