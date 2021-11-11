import 'package:controlly/homeassistant/entity.dart';

class HomeAssistantBinarySensorEntity extends HomeAssistantEntity {
  HomeAssistantBinarySensorEntity(id, parent, stateData)
      : super(
          id: id,
          parent: parent,
          type: HomeAssistantEntityType.switchEntity,
          stateData: stateData,
        );

  bool get isOn => stateData['state'] == 'on';

  @override
  String toString() => '$name (${isOn ? 'on' : 'off'})';
}
