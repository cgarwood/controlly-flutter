import 'package:controlly/utils/device_class_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yaml/yaml.dart';
import 'package:controlly/utils/helpers.dart';

Color getBackgroundColor(entity, config) {
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

  switch (entity.domain) {
    case "binary_sensor":
      if (BINARY_SENSOR_COLOR_INVERTED.contains(entity.deviceClass)) {
        return entity.state == "on" ? Colors.green : Colors.red;
      }
      return entity.state == "on" ? Colors.red : Colors.green;
    case "sensor":
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
    case "switch":
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
