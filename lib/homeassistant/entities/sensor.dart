import 'package:controlly/homeassistant/entity.dart';

class HomeAssistantSensorEntity extends HomeAssistantEntity {
  String? unitOfMeasurement;

  HomeAssistantSensorEntity(id, parent, stateData)
      : super(
          id: id,
          parent: parent,
          type: HomeAssistantEntityType.sensorEntity,
          stateData: stateData,
        ) {
    unitOfMeasurement = stateData['unit_of_measurement'];
  }

  @override
  void handleUpdate(Map<String, dynamic> newState) {
    super.handleUpdate(newState);
    unitOfMeasurement = newState['unit_of_measurement'];
  }

  @override
  String toString() => '$name ($state)';
}
