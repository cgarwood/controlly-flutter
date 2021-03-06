// TODO: Update to match current Home Assistant Climate Entity Model:
// https://developers.home-assistant.io/docs/core/entity/climate

import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/utils/ws.dart';

enum HomeAssistantFanMode { forcedOn, auto }
enum HomeAssistantHVACMode { heat, cool, auto }

class HomeAssistantClimateEntity extends HomeAssistantEntity {
  int? currentTemperature;
  int? currentSetTemperature;
  bool? fanOn;
  HomeAssistantFanMode fanMode = HomeAssistantFanMode.auto;
  HomeAssistantHVACMode hvacMode = HomeAssistantHVACMode.cool;
  String? hvacAction;
  int? targetTempHigh;
  int? targetTempLow;

  HomeAssistantClimateEntity(
    id,
    parent,
    stateData,
  ) : super(
          id: id,
          type: HomeAssistantEntityType.climateEntity,
          parent: parent,
          stateData: stateData,
        ) {
    currentSetTemperature = stateData['attributes']['temperature'];
    currentTemperature = stateData['attributes']['current_temperature'];
    fanOn = stateData['attributes']['fan_mode'] == 'on';
    fanMode = stateData['attributes']['fan_mode'] == 'on' ? HomeAssistantFanMode.forcedOn : HomeAssistantFanMode.auto;
    hvacMode = stateData['attributes']['hvac_mode'] == 'heat'
        ? HomeAssistantHVACMode.heat
        : stateData['attributes']['hvac_mode'] == 'cool'
            ? HomeAssistantHVACMode.cool
            : HomeAssistantHVACMode.auto;
    hvacAction = stateData['attributes']['hvac_action'];
    targetTempHigh = stateData['attributes']['target_temp_high'];
    targetTempLow = stateData['attributes']['target_temp_low'];
  }

  @override
  void handleUpdate(Map<String, dynamic> newState) {
    super.handleUpdate(newState);
    currentSetTemperature = newState['attributes']['temperature'];
    currentTemperature = newState['attributes']['current_temperature'];
    fanOn = newState['attributes']['fan_mode'] == 'on';
    fanMode = newState['attributes']['fan_mode'] == 'on' ? HomeAssistantFanMode.forcedOn : HomeAssistantFanMode.auto;
    hvacMode = newState['attributes']['hvac_mode'] == 'heat'
        ? HomeAssistantHVACMode.heat
        : newState['attributes']['hvac_mode'] == 'cool'
            ? HomeAssistantHVACMode.cool
            : HomeAssistantHVACMode.auto;
    hvacAction = newState['attributes']['hvac_action'];
    targetTempHigh = newState['attributes']['target_temp_high'];
    targetTempLow = newState['attributes']['target_temp_low'];
  }

  @override
  String toString() {
    String retval = name;
    if (currentTemperature != null) retval += ' ??? $currentTemperature';
    if (currentSetTemperature != null) retval += ' (${currentSetTemperature ?? ''})';
    return retval;
  }

  /// will preserve the existing hvacMode
  void setTemperature(int temp, [HomeAssistantHVACMode? hvacMode]) {
    if (type != HomeAssistantEntityType.climateEntity) return;
    this.hvacMode = hvacMode ?? this.hvacMode;
    transitioning = true;
    parent.send(WSMessage.fromMap({
      'type': 'call_service',
      'domain': 'climate',
      'service': 'set_temperature',
      'service_data': {
        'entity_id': id,
        'temperature': temp,
        'hvac_mode': this.hvacMode == HomeAssistantHVACMode.heat ? 'heat' : 'cool',
      }
    }));
  }

  /// will reset fan mode to auto
  void setFan([HomeAssistantFanMode fanMode = HomeAssistantFanMode.auto]) {
    this.fanMode = fanMode;
    if (type != HomeAssistantEntityType.climateEntity) return;
    transitioning = true;
    parent.send(WSMessage.fromMap({
      'type': 'call_service',
      'domain': 'climate',
      'service': 'set_fan_mode',
      'service_data': {
        'entity_id': id,
        'fan_mode': fanMode == HomeAssistantFanMode.forcedOn ? 'on' : 'auto',
      }
    }));
  }
}
