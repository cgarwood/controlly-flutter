import 'package:controlly/homeassistant/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../utils/helpers.dart';

class SensorWidget extends StatefulWidget {
  final HomeAssistantEntity entity;
  const SensorWidget({Key? key, required this.entity}) : super(key: key);

  @override
  _SensorWidgetState createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  HomeAssistantEntity get entity => widget.entity;

  // should return a text widget or an icon widget
  // use this to determine which kind of widget you want to be the
  // main state widget.
  Widget entityState() {
    switch (entity.type) {
      case HomeAssistantEntityType.sensorEntity:
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
          case 'battery':
            return Text(
              (entity.state ?? '') + '%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            );
          default:
            // TODO: return an icon if the state is 'charging' or 'discharging'
            return Text(
              (entity.state ?? ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            );
        }
      case HomeAssistantEntityType.climateEntity:
        var heat = const Icon(
          Icons.fireplace_outlined,
          color: Colors.white,
        );
        var cool = const Icon(
          Icons.ac_unit,
          color: Colors.white,
        );
        switch (entity.state) {
          case 'heat':
            return heat;
          case 'cool':
            return cool;
          default:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [heat, cool],
            );
        }

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

    return Container(
      width: 128,
      height: 128,
      padding: const EdgeInsets.all(8),
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
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              entity.deviceClass?.toTitleCase() ?? entity.domain.toTitleCase(),
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
