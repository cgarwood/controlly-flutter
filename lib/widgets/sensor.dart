import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../utils/helpers.dart';

class SensorWidget extends StatefulWidget {
  final HomeAssistantEntity entity;
  SensorWidget({Key? key, required this.entity}) : super(key: key);

  @override
  _SensorWidgetState createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  HomeAssistantEntity get entity => widget.entity;

  // will return a text widget or an icon widget
  // use this to determine which kind of widget you want to be the
  // main state widget.
  Widget entityState() {
    switch (entity.deviceClass) {

      // will use text and append a degree symbol
      case 'temperature':
        return Text(
          (entity.state ?? '') + '°',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'humidity':
        return Text(
          (entity.state ?? '') + '%',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return Text(
          (entity.state ?? ''),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // var entity = store.ha!.entities.firstWhere((e) => e.id == widget.entityId);

    // changed sized box and decorated box to just a Container since it does both
    return Container(
      width: 128,
      height: 128,
      padding: const EdgeInsets.all(8), // added padding
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)), // rounded corners
        color: !entity.available
            ? Colors.grey[300]
            : entity.state == 'on'
                ? Colors.green
                : Colors.red,
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // will take up as much of the column as it can
            // if you want this top state widget to take up a specific amount of space,
            // you'll need to replace this with a sized box and then play with
            // the positioning of the other items in the Column
            Expanded(
              child: Center(
                child: entityState(), // see above
              ),
            ),
            Text(
              entity.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w100,
              ),
            ),
            Text(
              entity.deviceClass?.toTitleCase() ?? '',
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
