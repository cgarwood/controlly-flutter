import 'package:controlly/homeassistant/entities/climate.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:controlly/widgets/common/tile.dart';
import 'package:controlly/widgets/common/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:yaml/yaml.dart';

class ClimateWidget extends StatefulWidget {
  final HomeAssistantClimateEntity entity;
  final YamlMap config;
  const ClimateWidget({Key? key, required this.entity, required this.config}) : super(key: key);

  @override
  _ClimateWidgetState createState() => _ClimateWidgetState();
}

class _ClimateWidgetState extends State<ClimateWidget> {
  HomeAssistantClimateEntity get entity => widget.entity;
  YamlMap get config => widget.config;

  Color get backgroundColor {
    if (config['color'] is String) {
      return (config['color'] as String).toColor();
    }

    if (config['color'] is YamlMap) {
      if (config['color'][entity.hvacAction] is String) {
        return (config['color'][entity.hvacAction] as String).toColor();
      }
    }

    if (entity.hvacAction == 'heating') {
      return Colors.orange.shade900;
    }
    if (entity.hvacAction == 'cooling') {
      return Colors.blue;
    }
    return Colors.white;
  }

  String get temperatureState {
    if (entity.currentSetTemperature.toString() == "null") {
      if (entity.targetTempHigh != null && entity.targetTempLow != null) {
        return '${entity.targetTempHigh} - ${entity.targetTempLow}';
      }
    }
    return entity.currentSetTemperature?.toString() ?? '--';
  }

  Widget entityState() {
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        (temperatureState + "\u00B0"),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1,
          color: stateColor,
        ),
      ),
    ]);
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
      backgroundColor: backgroundColor,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                      child: Center(
                        child: entityState(), // see above
                      ),
                    ),
                  ),
                  CommonTitleWidget(
                    entity: entity,
                    config: config,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    defaultSubtitle: entity.hvacAction?.toTitleCase(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        if (entity.currentSetTemperature == null) return;
                        entity.setTemperature(entity.currentSetTemperature! + 1);
                      },
                      child: Icon(MdiIcons.chevronUp, color: stateColor),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        if (entity.currentSetTemperature == null) return;
                        entity.setTemperature(entity.currentSetTemperature! - 1);
                      },
                      child: Icon(MdiIcons.chevronDown, color: stateColor),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
