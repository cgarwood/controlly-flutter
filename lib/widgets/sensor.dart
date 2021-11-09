import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/homeassistant/entities/sensor.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yaml/yaml.dart';
import 'package:controlly/utils/helpers.dart';

class SensorWidget extends StatefulWidget {
  final HomeAssistantEntity entity;
  final YamlMap config;
  const SensorWidget({Key? key, required this.entity, required this.config}) : super(key: key);

  @override
  _SensorWidgetState createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  HomeAssistantEntity get entity => widget.entity;
  YamlMap get config => widget.config;

  Widget entityState() {
    if (entity is HomeAssistantSensorEntity) {
      return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          (entity.state ?? ''),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        Text(
          ((entity as HomeAssistantSensorEntity).unitOfMeasurement ?? ''),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]);
    }

    return Text(
      (entity.state ?? ''),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color get entityColor {
    if (config['color'] is String) {
      return (config['color'] as String).toColor();
    }

    if (config['color'] is YamlMap) {
      // map based on states or a range
      if (config['color']['range'] is YamlMap) {
        return colorFromRange(entity.state, config['color']['range']['min'], config['color']['range']['max'],
            config['color']['range']['min_color'], config['color']['range']['max_color']);
      }

      if (config['color'][entity.state] is String) {
        return (config['color'][entity.state] as String).toColor();
      }
    }

    // Standard colors
    if (!entity.available) {
      return Colors.grey[300]!;
    }

    switch (entity.type) {
      case HomeAssistantEntityType.sensorEntity:
        switch (entity.deviceClass) {
          case 'temperature':
            return Colors.cyan[800]!;
          case 'humidity':
            return Colors.blue[600]!;
          case 'battery':
            return Colors.green;
          default:
            return Colors.grey;
        }
      case HomeAssistantEntityType.climateEntity:
        switch (entity.state) {
          case 'heat':
            return Colors.red;
          case 'cool':
            return Colors.blue;
        }
        break;
      case HomeAssistantEntityType.lightEntity:
      case HomeAssistantEntityType.scriptEntity:
      case HomeAssistantEntityType.switchEntity:
        return entity.state == 'on'
            ? Colors.green
            : entity.state == 'off'
                ? Colors.red
                : Colors.cyan[800]!;
      default:
        return Colors.cyan;
    }
    return Colors.cyan;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: entityColor,
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
                config['title'] ?? entity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                config['subtitle'] ?? entity.deviceClass?.toTitleCase() ?? entity.domain.toTitleCase(),
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
