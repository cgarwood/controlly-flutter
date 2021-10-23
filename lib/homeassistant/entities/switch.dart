import 'package:controlly/homeassistant/entity.dart';

class HomeAssistantSwitchEntity extends HomeAssistantSwitchableEntity {
  HomeAssistantSwitchEntity(id, parent, stateData)
      : super(
          id: id,
          parent: parent,
          type: HomeAssistantEntityType.switchEntity,
          stateData: stateData,
        );

  @override
  String toString() => '$name (${isOn ? 'on' : 'off'})';
}
