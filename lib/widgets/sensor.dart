import 'package:controlly/homeassistant/entity.dart';
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          case 'humidity':
          case 'battery':
            return Text(
              (entity.state ?? '') + '%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          default:
            // TODO: return an icon if the state is 'charging' or 'discharging'
            return Text(
              (entity.state ?? ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Color get entityColor {
    if (config['color'] is String) {
      return (config['color'] as String).toColor();
    }

    if (config['color'] is YamlMap) {
      // map based on states or a range
      if (config['color']['range'] is YamlMap) {
        double min = (config['color']['range']['min'] ?? 50).toDouble();
        double max = (config['color']['range']['max'] ?? 90).toDouble();
        double state = double.parse(entity.state!);
        double percent = (state - min) / (max - min);
        if (percent > 1) {
          percent = 1;
        }
        if (percent < 0) {
          percent = 0;
        }

        HSLColor minColor = HSLColor.fromAHSL(1, (config['color']['range']['min_hue'] ?? 240).toDouble(), 1, 0.3);
        HSLColor maxColor = HSLColor.fromAHSL(1, (config['color']['range']['max_hue'] ?? 1).toDouble(), 1, 0.3);
        return HSLColor.lerp(minColor, maxColor, percent)!.toColor();
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
