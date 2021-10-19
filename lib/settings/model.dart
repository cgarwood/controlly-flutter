import 'dart:async';

import 'package:get_storage/get_storage.dart';

class SettingsManager {
  bool loaded = false;
  Future<bool>? ready;
  late GetStorage box;

  get getItem => box.read;
  get setItem => box.write;

  String get haUrl => getItem('haUrl') ?? '';
  set haUrl(String url) => setItem('haUrl', url);

  String get snapcastUrl => getItem('snapcastUrl') ?? '';
  set snapcastUrl(String url) => setItem('snapcastUrl', url);

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
