import 'dart:async';

import 'package:controlly/homeassistant/model.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:controlly/utils/ws.dart';

enum HomeAssistantEntityType {
  switchEntity,
  scriptEntity,
  climateEntity,
  sensorEntity,
  lightEntity,
  mediaPlayerEntity,
  groupEntity,
  inputEntity,
  sceneEntity,
  automationEntity,
  cameraEntity,
  binarySensorEntity,
  genericEntity,
}

// ignore: constant_identifier_names
const UNAVAILABLE_STATES = ['unavailable', 'unknown'];

class HomeAssistantEntity {
  // internal fields
  String id;
  late String domain;
  HomeAssistantEntityType type;
  HomeAssistant parent;
  Map<String, dynamic> stateData;

  // Home Assistant entity properties:
  // https://developers.home-assistant.io/docs/core/entity#generic-properties
  late String name;
  String? state;
  bool available = false;
  String? deviceClass;
  String? entityCategory;
  bool assumedState = false;
  String? entityPicture;
  String? icon;

  Map attributes = {};

  bool _transitioning = false;
  bool get transitioning => _transitioning;
  set transitioning(bool b) {
    _transitioning = b;
    notify();
  }

  final StreamController<bool> _updateController = StreamController<bool>.broadcast();
  Stream<bool> get updates => _updateController.stream;

  void notify() => _updateController.add(true);
  void close() => _updateController.close();

  HomeAssistantEntity({required this.id, required this.type, required this.parent, required this.stateData}) {
    domain = id.split('.')[0];
    name = computeStateName(stateData);
    state = stateData['state'];
    available = !UNAVAILABLE_STATES.contains(stateData['state']);
    deviceClass = stateData['attributes']['device_class'];
    entityCategory = stateData['attributes']['entity_category'];
    assumedState = stateData['attributes']['assumed_state'] ?? false;
    entityPicture = stateData['attributes']['entity_picture'];
    icon = stateData['attributes']['icon'];
    attributes = stateData['attributes'];
  }

  void handleUpdate(Map<String, dynamic> newState) {
    stateData = newState;
    state = newState['state'];
    attributes = newState['attributes'];
    available = !UNAVAILABLE_STATES.contains(stateData['state']);
    name = computeStateName(stateData);
    deviceClass = newState['attributes']['device_class'];
    entityCategory = newState['attributes']['entity_category'];
    icon = newState['attributes']['icon'];
    entityPicture = newState['attributes']['entity_picture'];
    assumedState = newState['attributes']['assumed_state'] ?? false;
    notify();
  }
}

class HomeAssistantSwitchableEntity extends HomeAssistantEntity {
  HomeAssistantSwitchableEntity({
    required String id,
    required HomeAssistantEntityType type,
    required HomeAssistant parent,
    required Map<String, dynamic> stateData,
  }) : super(id: id, type: type, parent: parent, stateData: stateData);

  bool get isOn => state == 'on';
  set isOn(bool b) {
    if (b) {
      state = 'on';
    } else {
      state = 'off';
    }
  }

  void turnOn() {
    toggle(true);
  }

  void turnOff() {
    toggle(false);
  }

  // null = toggle, turnOn = on, else off
  void toggle([bool? turnOn]) {
    transitioning = true;
    var service = turnOn == null
        ? 'toggle'
        : turnOn
            ? 'turn_on'
            : 'turn_off';
    parent.send(WSMessage.fromMap({
      'type': 'call_service',
      'domain': domain,
      'service': service,
      'service_data': {
        'entity_id': id,
      }
    }));
  }
}
