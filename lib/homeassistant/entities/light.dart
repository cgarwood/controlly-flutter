import 'package:controlly/homeassistant/entity.dart';

class HomeAssistantLightEntity extends HomeAssistantEntity {
  int? brightness;

  HomeAssistantLightEntity(id, parent, stateData)
      : super(
          id: id,
          parent: parent,
          type: HomeAssistantEntityType.sensorEntity,
          stateData: stateData,
        ) {
    brightness = stateData['brightness'];
  }

  @override
  void handleUpdate(Map<String, dynamic> newState) {
    super.handleUpdate(newState);
    brightness = newState['brightness'];
  }

  @override
  String toString() => '$name ($state)';
}
