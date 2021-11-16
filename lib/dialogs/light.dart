import 'package:controlly/dialogs/general.dart';
import 'package:controlly/homeassistant/entities/light.dart';
import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/store.dart';
import 'package:controlly/utils/colors.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yaml/yaml.dart';

class LightDialog extends StatefulWidget {
  final HomeAssistantEntity entity;
  final YamlMap config;
  const LightDialog({
    Key? key,
    required this.entity,
    required this.config,
  }) : super(key: key);

  @override
  _LightDialogState createState() => _LightDialogState();
}

class _LightDialogState extends State<LightDialog> {
  HomeAssistantEntity get entity => widget.entity;
  YamlMap get config => widget.config;

  bool sliderChanged = false;
  double brightness = 0;

  Color get backgroundColor {
    return getBackgroundColor(entity, config);
  }

  @override
  Widget build(BuildContext context) {
    print(entity.attributes);
    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder(
          stream: store.ha!.updates,
          builder: (context, snapshot) {
            if (!sliderChanged) {
              brightness = convert255ToPct((entity as HomeAssistantLightEntity).brightness ?? 0);
            } else {
              sliderChanged = false;
            }
            return GeneralDialog(
              header: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Switch(
                  value: entity.state == 'on',
                  onChanged: (value) {
                    (entity as HomeAssistantLightEntity).toggle(value);
                  },
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    entity.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeago.format(entity.lastUpdated!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ]),
              ]),
              body: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Brightness',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: Slider(
                        value: brightness,
                        min: 0,
                        max: 100,
                        onChanged: (value) => setState(() {
                          sliderChanged = true;
                          brightness = value;
                        }),
                        onChangeEnd: (value) =>
                            (entity as HomeAssistantLightEntity).setBrightness(convertPctTo255(value)),
                      ),
                    ),
                  ],
                ),
                if ((entity as HomeAssistantLightEntity).supportsColor && entity.state == "on")
                  Column(children: [
                    const Padding(padding: EdgeInsets.all(8.0)),
                    ColorPicker(
                      pickerColor: Color.fromRGBO(
                          (entity as HomeAssistantLightEntity).rgbColor?[0] ?? 0,
                          (entity as HomeAssistantLightEntity).rgbColor?[1] ?? 0,
                          (entity as HomeAssistantLightEntity).rgbColor?[2] ?? 0,
                          1),
                      enableAlpha: false,
                      paletteType: PaletteType.hueWheel,
                      colorPickerWidth: 160,
                      labelTypes: const [],
                      onColorChanged: (value) => (entity as HomeAssistantLightEntity).setColor(value),
                    ),
                  ]),
              ]),
            );
          });
    });
  }
}
