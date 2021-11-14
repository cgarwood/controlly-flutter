import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/utils/ws.dart';

class HomeAssistantLightEntity extends HomeAssistantSwitchableEntity {
  int? brightness;

  HomeAssistantLightEntity(id, parent, stateData)
      : super(
          id: id,
          parent: parent,
          type: HomeAssistantEntityType.lightEntity,
          stateData: stateData,
        ) {
    brightness = stateData['attributes']['brightness'];
  }

  @override
  void handleUpdate(Map<String, dynamic> newState) {
    super.handleUpdate(newState);
    brightness = newState['attributes']['brightness'];
  }

  void setBrightness(int brightness) {
    parent.send(WSMessage.fromMap({
      'type': 'call_service',
      'domain': domain,
      'service': 'turn_on',
      'service_data': {'entity_id': id, 'brightness': brightness}
    }));
  }

  @override
  String toString() => '$name ($state)';
}
