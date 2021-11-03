// Widget Definitions & Defaults

import 'package:controlly/widgets/sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget getWidget(String key, entity, config) {
  switch (key) {
    case 'sensor':
      return SensorWidget(entity: entity, config: config);
    default:
      return Container();
  }
}

// ignore: constant_identifier_names
const WIDGET_DEFAULT_SIZES = {
  "sensor": {"width": 1, "height": 1}
};
