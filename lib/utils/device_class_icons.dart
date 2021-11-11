// Reference:
// https://github.com/home-assistant/frontend/blob/dev/src/common/entity/binary_sensor_icon.ts

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

getIconFromDeviceClass(dynamic entity) {
  //ignore: non_constant_identifier_names
  bool is_off = entity.state == 'off';

  switch (entity.deviceClass) {
    case "battery":
      return is_off ? MdiIcons.battery : MdiIcons.batteryOutline;
    case "battery_charging":
      return is_off ? MdiIcons.battery : MdiIcons.batteryCharging;
    case "cold":
      return is_off ? MdiIcons.thermometer : MdiIcons.snowflake;
    case "connectivity":
      return is_off ? MdiIcons.closeNetworkOutline : MdiIcons.checkNetworkOutline;
    case "door":
      return is_off ? MdiIcons.doorClosed : MdiIcons.doorOpen;
    case "garage_door":
      return is_off ? MdiIcons.garage : MdiIcons.garageOpen;
    case "power":
      return is_off ? MdiIcons.powerPlugOff : MdiIcons.powerPlug;
    case "gas":
    case "problem":
    case "safety":
    case "tamper":
      return is_off ? MdiIcons.checkCircle : MdiIcons.alertCircle;
    case "smoke":
      return is_off ? MdiIcons.checkCircle : MdiIcons.smoke;
    case "heat":
      return is_off ? MdiIcons.thermometer : MdiIcons.fire;
    case "light":
      return is_off ? MdiIcons.brightness5 : MdiIcons.brightness7;
    case "lock":
      return is_off ? MdiIcons.lock : MdiIcons.lockOpen;
    case "moisture":
      return is_off ? MdiIcons.waterOff : MdiIcons.water;
    case "motion":
      return is_off ? MdiIcons.walk : MdiIcons.run;
    case "occupancy":
      return is_off ? MdiIcons.homeOutline : MdiIcons.home;
    case "opening":
      return is_off ? MdiIcons.square : MdiIcons.squareOutline;
    case "plug":
      return is_off ? MdiIcons.powerPlugOff : MdiIcons.powerPlug;
    case "presence":
      return is_off ? MdiIcons.homeOutline : MdiIcons.home;
    case "running":
      return is_off ? MdiIcons.stop : MdiIcons.play;
    case "sound":
      return is_off ? MdiIcons.musicNoteOff : MdiIcons.musicNote;
    case "update":
      return is_off ? MdiIcons.package : MdiIcons.packageUp;
    case "vibration":
      return is_off ? MdiIcons.cropPortrait : MdiIcons.vibrate;
    case "window":
      return is_off ? MdiIcons.windowClosed : MdiIcons.windowOpen;
    default:
      return is_off ? MdiIcons.radioboxBlank : MdiIcons.checkboxMarkedCircle;
  }
}

//ignore: constant_identifier_names
const FIXED_DOMAIN_ICONS = {
  "alert": MdiIcons.alert,
  "air_quality": MdiIcons.airFilter,
  "automation": MdiIcons.robot,
  "calendar": MdiIcons.calendar,
  "camera": MdiIcons.video,
  "climate": MdiIcons.thermostat,
  "configurator": MdiIcons.cog,
  "conversation": MdiIcons.textToSpeech,
  "counter": MdiIcons.counter,
  "fan": MdiIcons.fan,
  "google_assistant": MdiIcons.googleAssistant,
  "group": MdiIcons.googleCirclesCommunities,
  "homeassistant": MdiIcons.homeAssistant,
  "homekit": MdiIcons.homeAutomation,
  "image_processing": MdiIcons.imageFilterFrames,
  "input_boolean": MdiIcons.toggleSwitchOutline,
  "input_datetime": MdiIcons.calendarClock,
  "input_number": MdiIcons.rayVertex,
  "input_select": MdiIcons.formatListBulleted,
  "input_text": MdiIcons.formTextbox,
  "light": MdiIcons.lightbulb,
  "mailbox": MdiIcons.mailbox,
  "notify": MdiIcons.commentAlert,
  "number": MdiIcons.rayVertex,
  "persistent_notification": MdiIcons.bell,
  "person": MdiIcons.account,
  "plant": MdiIcons.flower,
  "proximity": MdiIcons.appleSafari,
  "remote": MdiIcons.remote,
  "scene": MdiIcons.palette,
  "script": MdiIcons.scriptText,
  "select": MdiIcons.formatListBulleted,
  "sensor": MdiIcons.eye,
  "siren": MdiIcons.bullhorn,
  "simple_alarm": MdiIcons.bell,
  "sun": MdiIcons.whiteBalanceSunny,
  "timer": MdiIcons.timerOutline,
  "updater": MdiIcons.cloudUpload,
  "vacuum": MdiIcons.robotVacuum,
  "water_heater": MdiIcons.thermometer,
  "weather": MdiIcons.weatherCloudy,
  "zone": MdiIcons.mapMarkerRadius,
};

//ignore: constant_identifier_names
const FIXED_DEVICE_CLASS_ICONS = {
  "aqi": MdiIcons.airFilter,
  // battery": MdiIcons.battery, => not included by design since `sensorIcon()` will dynamically determine the icon
  "carbon_dioxide": MdiIcons.moleculeCo2,
  "carbon_monoxide": MdiIcons.moleculeCo,
  "current": MdiIcons.currentAc,
  "date": MdiIcons.calendar,
  "energy": MdiIcons.lightningBolt,
  "gas": MdiIcons.gasCylinder,
  "humidity": MdiIcons.waterPercent,
  "illuminance": MdiIcons.brightness5,
  "monetary": MdiIcons.cash,
  "nitrogen_dioxide": MdiIcons.molecule,
  "nitrogen_monoxide": MdiIcons.molecule,
  "nitrous_oxide": MdiIcons.molecule,
  "ozone": MdiIcons.molecule,
  "pm1": MdiIcons.molecule,
  "pm10": MdiIcons.molecule,
  "pm25": MdiIcons.molecule,
  "power": MdiIcons.flash,
  "power_factor": MdiIcons.angleAcute,
  "pressure": MdiIcons.gauge,
  "signal_strength": MdiIcons.wifi,
  "sulphur_dioxide": MdiIcons.molecule,
  "temperature": MdiIcons.thermometer,
  "timestamp": MdiIcons.clock,
  "volatile_organic_compounds": MdiIcons.molecule,
  "voltage": MdiIcons.sineWave,
};

//ignore: constant_identifier_names
const BINARY_SENSOR_COLOR_INVERTED = [
  "battery_charging",
  "connectivity",
  "light",
  "moving",
  "plug",
  "power",
  "presence",
  "running",
];
