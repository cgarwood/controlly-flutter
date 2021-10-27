import 'package:controlly/homeassistant/homeassistant.dart';
import 'package:controlly/store.dart';
import 'package:flutter/material.dart';

import 'package:controlly/settings/model.dart';

final Map configItems = {
  // 'haUrl': {'type': 'text', 'name': 'Home Assistant URL', 'description': 'URL to your Home Assistant instance'},
  'haHost': {
    'type': 'text',
    'name': 'Home Assistant Hostname',
    'description': 'Hostname for your Home Assistant instance'
  },
  'haPort': {'type': 'text', 'name': 'Home Assistant Port Number', 'description': 'Usually 8123'},
  'haSSL': {'type': 'bool', 'name': 'Use SSL for Home Assistant', 'description': ''},
  'haToken': {'type': 'text', 'name': 'Home Assistant Long-Lived Token', 'description': ''},
  'snapcastUrl': {
    'type': 'text',
    'name': 'Snapcast Server Address',
    'description': 'IP or hostname to your Snapcast server'
  },
  "certificateVerification": {
    'type': 'bool',
    'name': 'Verify SSL Certificates',
    'description': 'Require valid (trusted) SSL certificates'
  }
};

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  String? formValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controlly Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: configItems.length + 1,
        itemBuilder: (BuildContext context, int index) {
          // final element is a connect button
          if (index == configItems.length) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // attempt to connect
                    store.ha?.destroy();
                    store.ha = HomeAssistant(HomeAssistantSettings(
                      ip: settingsManager.getItem('haHost') ?? '',
                      port: int.tryParse(settingsManager.getItem('haPort')) ?? 8123,
                      ssl: settingsManager.getItem('haSSL') ?? false,
                      longLivedToken: settingsManager.getItem('haToken') ?? '',
                    ));
                    await store.ha!.connect();
                    if (store.ha!.connected) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('CONNECT'),
                ),
              ],
            );
          }

          // this is clever... might be overkill when we are dealing with just a few settings
          String key = configItems.keys.elementAt(index);
          Map configItem = configItems[key];
          if (configItem['type'] == "text") {
            return TextFormField(
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: configItem['name'],
                helperText: configItem['description'],
              ),
              onChanged: (newVal) async {
                await settingsManager.setItem(key, newVal);
              },
            );
            // return ListTile(
            //   title: Text(configItem['name']),
            //   subtitle: Text(settingsManager.getItem(key) ?? ''),
            //   enabled: true,
            //   onTap: () async {
            //     formValue = settingsManager.getItem(key);
            //     var newVal = await _showConfigDialog(key, settingsManager.getItem(key) ?? '');
            //     if (newVal != null) await settingsManager.setItem(key, newVal);
            //     refresh();
            //   },
            // );
          }
          if (configItem['type'] == "bool") {
            return SwitchListTile(
              title: Text(configItem['name']),
              subtitle: Text(configItem['description'] ?? ''),
              value: settingsManager.getItem(key) ?? false,
              onChanged: (value) {
                settingsManager.setItem(key, value);
                refresh();
              },
            );
          }
          return ListTile(
            title: Text(configItem['name']),
            subtitle: Text(settingsManager.getItem(key) ?? ''),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }

  Future<String?> _showConfigDialog(String key, [String initialValue = '']) async {
    Map configItem = configItems[key];
    var type = configItem['type'];
    var name = configItem['name'];
    var description = configItem['description'];
    var controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        Widget formField;
        if (type == "text") {
          formField = TextFormField(
            controller: controller,
            decoration: const InputDecoration(border: UnderlineInputBorder()),
            onChanged: (value) {},
          );
        } else {
          formField = const Text('invalid type for config item');
        }
        return AlertDialog(
          title: Text(name ?? key),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(description ?? ''),
              formField,
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            )
          ],
        );
      },
    );
  }
}
