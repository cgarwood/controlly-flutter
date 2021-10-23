import 'package:controlly/store.dart';
import 'package:flutter/material.dart';

class SensorWidget extends StatefulWidget {
  String entityId;
  String? state;
  bool? available;

  SensorWidget({Key? key, required this.entityId});

  @override
  _SensorWidgetState createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  @override
  Widget build(BuildContext context) {
    var entity = store.ha!.entities.firstWhere((e) => e.id == widget.entityId);
    return SizedBox(
      width: 128,
      height: 128,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: entity.state == 'on' ? Colors.green : Colors.red,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.entityId),
            Text(entity.state ?? ''),
            Text(entity.available ?? true ? 'available' : 'unavailable'),
          ],
        ),
      ),
    );
  }
}
