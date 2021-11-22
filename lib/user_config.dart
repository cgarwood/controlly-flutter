import 'package:controlly/settings/model.dart';
import 'package:controlly/store.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

Future<bool> loadUserConfig() async {
  var configPath = settingsManager.getItem('configYaml');
  if (configPath == null) {
    return false;
  }

  var response = await http.get(Uri.parse(configPath));
  if (response.statusCode == 200) {
    try {
      store.userConfig = loadYaml(response.body);
    } catch (e) {
      showErrorDialog(
        title: 'Error loading controlly configuration',
        body: 'The following error occured when trying to parse the controlly configuration:',
        exception: e,
      );
      return false;
    }
    return true;
  }
  return false;
}
