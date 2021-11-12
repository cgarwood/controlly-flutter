import 'package:controlly/settings/model.dart';
import 'package:controlly/store.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

Future<bool> loadUserConfig() async {
  var configPath = settingsManager.getItem('configYaml');
  if (configPath == null) {
    return false;
  }

  var response = await http.get(Uri.parse(configPath));
  if (response.statusCode == 200) {
    store.userConfig = loadYaml(response.body);
    return true;
  }
  return false;
}
