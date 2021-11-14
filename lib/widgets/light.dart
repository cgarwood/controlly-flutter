import 'package:controlly/dialogs/light.dart';
import 'package:controlly/homeassistant/entities/light.dart';
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

class LightWidget extends StatefulWidget {
  final HomeAssistantEntity entity;
  final YamlMap config;
  const LightWidget({Key? key, required this.entity, required this.config}) : super(key: key);

  @override
  _LightWidgetState createState() => _LightWidgetState();
}

class _LightWidgetState extends State<LightWidget> {
  HomeAssistantEntity get entity => widget.entity;
  YamlMap get config => widget.config;

  Color get lightColor {
    if (entity.state == 'on') {
      return Colors.yellow;
    }
    return Colors.grey;
  }

  Widget entityState() {
    int brightness = (((entity as HomeAssistantLightEntity).brightness ?? 0).toInt() / 255 * 100).round();
    brightness.roundToDouble();
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [Icon(entityIcon, size: 40, color: lightColor)]),
          brightness > 0
              ? Column(children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8),
                      child: SizedBox(
                        height: 28,
                        width: 28,
                        child: Stack(
                          children: [
                            Center(
                              child: CircularProgressIndicator(
                                  value: brightness / 100,
                                  backgroundColor: Colors.grey,
                                  color: Colors.yellow,
                                  strokeWidth: 3),
                            ),
                            Center(
                                child: Text("$brightness%",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 10))),
                          ],
                        ),
                      )),
                ])
              : Container(),
        ]);
  }

  IconData get entityIcon {
    if (config['icon'] is String) {
      return MdiIcons.fromString(config['icon']) ?? MdiIcons.radioboxBlank;
    }
    if (config['icon'] is YamlMap) {
      return MdiIcons.fromString(config['icon'][entity.state]) ?? MdiIcons.radioboxBlank;
    }
    if (entity.icon != null) {
      return MdiIcons.fromString(entity.icon!) ?? MdiIcons.radioboxBlank;
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
      onTap: () => (entity as HomeAssistantLightEntity).toggle(),
      onLongPress: () => showDialog(
          context: context,
          builder: (context) => LightDialog(
                entity: entity,
                config: config,
              )),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
              defaultSubtitle: entity.state!.toTitleCase(),
            )
          ],
        ),
      ),
    );
  }
}
