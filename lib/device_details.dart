import 'package:battery_plus/battery_plus.dart';
import 'package:controlly/store.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DeviceDetails {
  final battery = Battery();
  final netinfo = NetworkInfo();

  Map<String, dynamic> batteryInfo = {"state": null, "level": null};

  Map<String, dynamic> wifiInfo = {
    "ssid": null,
    "ip": null,
  };

  void initialize() {
    store.device = {
      "battery": batteryInfo,
      "wifi": wifiInfo,
    };

    getWifiSettings();
    getBatteryInfo();

    battery.onBatteryStateChanged.listen((BatteryState state) {
      store.device['battery']['state'] = state.toString().split(".")[1];
    });
  }

  void getWifiSettings() async {
    store.device['wifi'] = {
      'ssid': await netinfo.getWifiName(),
      'ip': await netinfo.getWifiIP(),
    };
  }

  void getBatteryInfo() async {
    store.device['battery']['level'] = await battery.batteryLevel;
  }
}
