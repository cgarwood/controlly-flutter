import 'package:controlly/homeassistant/entities/light.dart';
import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/store.dart';
import 'package:controlly/utils/colors.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder(
          stream: store.ha!.updates,
          builder: (context, snapshot) {
            if (!sliderChanged) {
              brightness = convert255ToPct((entity as HomeAssistantLightEntity).brightness ?? 0);
            } else {
              sliderChanged = false;
            }
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(24),
                width: 550,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          entity.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          });
    });
  }
}
