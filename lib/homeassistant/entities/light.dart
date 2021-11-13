import 'package:controlly/homeassistant/entity.dart';

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

  @override
  String toString() => '$name ($state)';
}
