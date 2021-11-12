import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/homeassistant/entities/sensor.dart';
import 'package:controlly/utils/colors.dart';
import 'package:controlly/widgets/common/tile.dart';
import 'package:controlly/widgets/common/title.dart';

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
  Color get backgroundColor => getBackgroundColor(entity, config);

  Widget entityState() {
    if (entity is HomeAssistantSensorEntity) {
      return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          (entity.state ?? ''),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1,
            color: stateColor,
          ),
        ),
        Text(
          ((entity as HomeAssistantSensorEntity).unitOfMeasurement ?? ''),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: stateColor,
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
    if (backgroundColor == Colors.white) {
      return Colors.black;
    }
    if (config['text_color'] != null) {
      return (config['text_color'] as String).toColor();
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    String textColor = config['text_color'] ?? (backgroundColor == Colors.white ? 'dark' : 'light');
    String? subtitleColor = config['subtitle_color'];

    return CommonTileWidget(
      entity: entity,
      config: config,
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
    );
  }
}
