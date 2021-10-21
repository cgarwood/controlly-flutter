import 'package:flutter/material.dart';

import 'package:controlly/settings/model.dart';

final Map configItems = {
  'haUrl': {'type': 'text', 'name': 'Home Assistant URL', 'description': 'URL to your Home Assistant instance'},
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

  String? formValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Controlly Settings')),
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: configItems.length,
          itemBuilder: (BuildContext context, int index) {
            String key = configItems.keys.elementAt(index);
            Map configItem = configItems[key];
            if (configItem['type'] == "text") {
              return ListTile(
                  title: Text(configItem['name']),
                  subtitle: Text(settingsManager.get(key) ?? ''),
                  enabled: true,
                  onTap: () {
                    formValue = settingsManager.get(key);
                    _showConfigDialog(key);
                  });
            }
            if (configItem['type'] == "bool") {
              return SwitchListTile(
                  title: Text(configItem['name']),
                  subtitle: Text(configItem['description'] ?? ''),
                  value: settingsManager.get(key),
                  onChanged: (value) {
                    setState(() {
                      settingsManager.setItem(key, value);
                    });
                  });
            }
            return ListTile(
              title: Text(configItem['name']),
              subtitle: Text(settingsManager.get(key) ?? ''),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ));
  }

  Future<void> _showConfigDialog(String key) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          Map configItem = configItems[key];
          Widget formField;
          if (configItem['type'] == "text") {
            formField = TextFormField(
              decoration: const InputDecoration(border: UnderlineInputBorder()),
              initialValue: settingsManager.get(key) ?? '',
              onChanged: (value) {
                setState(() {
                  formValue = value;
                });
              },
            );
          } else {
            formField = const Text('invalid type for config item');
          }
          return AlertDialog(
            title: Text(configItem['name']),
            content: SizedBox(
                width: 400,
                height: 200,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[Text(configItem['description']), formField])),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() {
                    settingsManager.setItem(key, formValue);
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          );
        });
  }
}
