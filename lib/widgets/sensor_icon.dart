import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/widgets/common/title.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:yaml/yaml.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:controlly/utils/device_class_icons.dart';

class SensorIconWidget extends StatefulWidget {
  final HomeAssistantEntity entity;
  final YamlMap config;
  const SensorIconWidget({Key? key, required this.entity, required this.config}) : super(key: key);

  @override
  _SensorIconWidgetState createState() => _SensorIconWidgetState();
}

class _SensorIconWidgetState extends State<SensorIconWidget> {
  HomeAssistantEntity get entity => widget.entity;
  YamlMap get config => widget.config;

  Widget entityState() {
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(entityIcon, size: 40, color: Colors.white),
    ]);
  }

  IconData get entityIcon {
    if (config['icon'] is String) {
      return MdiIcons.fromString(config['icon']) ?? MdiIcons.radioboxBlank;
    }
    if (config['icon'] is YamlMap) {
      return MdiIcons.fromString(config['icon'][entity.state]) ?? MdiIcons.radioboxBlank;
    }
    if (entity.deviceClass != null) {
      if (entity.domain == "binary_sensor") {
        return getIconFromDeviceClass(entity);
      }
      return FIXED_DEVICE_CLASS_ICONS[entity.deviceClass] ?? MdiIcons.radioboxBlank;
    }
    return FIXED_DOMAIN_ICONS[entity.domain] ?? MdiIcons.radioboxBlank;
  }

  Color get entityColor {
    if (config['color'] is String) {
      return (config['color'] as String).toColor();
    }

    if (config['color'] is YamlMap) {
      if (config['color'][entity.state] is String) {
        return (config['color'][entity.state] as String).toColor();
      }
    }

    // Standard colors
    if (!entity.available) {
      return Colors.grey[300]!;
    }

    switch (entity.domain) {
      case "binary_sensor":
        if (BINARY_SENSOR_COLOR_INVERTED.contains(entity.deviceClass)) {
          return entity.state == "on" ? Colors.green : Colors.red;
        }
        return entity.state == "on" ? Colors.red : Colors.green;
      case "climate":
        switch (entity.state) {
          case 'heat':
            return Colors.red;
          case 'cool':
            return Colors.blue;
        }
        break;
      case "light":
      case "script":
      case "sensor":
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

  Color get stateColor {
    if (config['state_color'] != null) {
      return (config['state_color'] as String).toColor();
    }
    if (config['text_color'] == 'light') {
      return Colors.white;
    }
    if (config['text_color'] == 'dark') {
      return Colors.black;
    }
    if (entityColor == Colors.white) {
      return Colors.black;
    }
    if (config['text_color'] != null) {
      return (config['text_color'] as String).toColor();
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    String textColor = config['text_color'] ?? (entityColor == Colors.white ? 'dark' : 'light');
    String? subtitleColor = config['subtitle_color'];

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
              CommonTitleWidget(
                entity: entity,
                config: config,
                textColor: textColor,
                subtitleColor: subtitleColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
