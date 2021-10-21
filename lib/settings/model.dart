import 'dart:async';

import 'package:get_storage/get_storage.dart';

class SettingsManager {
  bool loaded = false;
  late Future<bool> ready;
  late GetStorage box;

  T? Function<T>(String) get getItem => box.read;
  Future<void> Function(String, dynamic) get setItem => box.write;

  Map<String, dynamic> get haSettings => getItem('haSettings') ?? {};
  set haSettings(Map<String, dynamic> settings) => setItem('haSettings', settings);

  String get snapcastUrl => getItem('snapcastUrl') ?? '';
  set snapcastUrl(String url) => setItem('snapcastUrl', url);

  bool get certificateVerification => getItem('certificateVerification') ?? true;
  set certificateVerification(bool value) => setItem('certificateVerification', value);

  SettingsManager() {
    box = GetStorage('controlly');
    ready = load();
  }

  Future<bool> load() async {
    await GetStorage.init();
    return true;
  }
}

SettingsManager settingsManager = SettingsManager();
