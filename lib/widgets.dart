// Widget Definitions & Defaults

import 'package:controlly/widgets/light.dart';
import 'package:controlly/widgets/sensor.dart';
import 'package:controlly/widgets/sensor_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget getWidget(String key, entity, config) {
  switch (key) {
    case 'light':
      return LightWidget(entity: entity, config: config);
    case 'sensor':
      return SensorWidget(entity: entity, config: config);
    case 'sensor_icon':
      return SensorIconWidget(entity: entity, config: config);
    default:
      return Container();
  }
}

// ignore: constant_identifier_names
const WIDGET_DEFAULT_SIZES = {
  "light": {"width": 1, "height": 1},
  "sensor": {"width": 1, "height": 1},
  "sensor_icon": {"width": 1, "height": 1},
};
