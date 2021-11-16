import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/utils/ws.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';

class HomeAssistantLightEntity extends HomeAssistantSwitchableEntity {
  Set<String> possibleColorModes = <String>{
    "rgb",
    "rgbw",
    "rgbww",
    "hs",
    "xy",
  };
  int? brightness;
  String? colorMode;
  List<dynamic>? supportedColorModes;
  int? colorTemp;
  List<dynamic>? rgbColor;

  HomeAssistantLightEntity(id, parent, stateData)
      : super(
          id: id,
          parent: parent,
          type: HomeAssistantEntityType.lightEntity,
          stateData: stateData,
        ) {
    brightness = stateData['attributes']['brightness'];
    colorMode = stateData['attributes']['color_mode'];
    supportedColorModes = stateData['attributes']['supported_color_modes'];
    colorTemp = stateData['attributes']['color_temp'];
    rgbColor = stateData['attributes']['rgb_color'];
  }

  @override
  void handleUpdate(Map<String, dynamic> newState) {
    super.handleUpdate(newState);
    brightness = newState['attributes']['brightness'];
    colorMode = stateData['attributes']['color_mode'];
    supportedColorModes = stateData['attributes']['supported_color_modes'];
    colorTemp = stateData['attributes']['color_temp'];
    rgbColor = stateData['attributes']['rgb_color'];
  }

  void setBrightness(int brightness) {
    parent.send(WSMessage.fromMap({
      'type': 'call_service',
      'domain': domain,
      'service': 'turn_on',
      'service_data': {'entity_id': id, 'brightness': brightness}
    }));
  }

  void setColor(dynamic color) {
    EasyDebounce.debounce('light-entity-setColor', const Duration(milliseconds: 500), () {
      List rgbColor = [];
      if (color is Color) {
        rgbColor = [color.red, color.green, color.blue];
      } else if (color is List<int>) {
        rgbColor = color;
      } else {
        throw Exception('Invalid color type');
      }

      parent.send(WSMessage.fromMap({
        'type': 'call_service',
        'domain': domain,
        'service': 'turn_on',
        'service_data': {'entity_id': id, 'rgb_color': rgbColor}
      }));
    });
  }

  bool get supportsColor {
    if (supportedColorModes == null) {
      return false;
    }
    if (supportedColorModes!.isEmpty) {
      return false;
    }
    Set<dynamic> supportedColorModesSet = supportedColorModes!.toSet();
    return supportedColorModesSet.intersection(possibleColorModes).isNotEmpty;
  }

  @override
  String toString() => '$name ($state)';
}
