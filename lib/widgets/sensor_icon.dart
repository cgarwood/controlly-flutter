import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/utils/colors.dart';
import 'package:controlly/utils/device_class_icons.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:controlly/widgets/common/tile.dart';
import 'package:controlly/widgets/common/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:yaml/yaml.dart';

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

  Color get backgroundColor => getBackgroundColor(entity, config);

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
