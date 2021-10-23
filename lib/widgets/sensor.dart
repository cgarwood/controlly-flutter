import 'package:controlly/store.dart';
import 'package:flutter/material.dart';

class SensorWidget extends StatefulWidget {
  String entityId;

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
          color: !entity.available
              ? Colors.grey[300]
              : entity.state == 'on'
                  ? Colors.green
                  : Colors.red,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 8),
            Text(entity.name, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(entity.state ?? '',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(entity.available ? 'available' : 'unavailable'),
          ],
        ),
      ),
    );
  }
}
