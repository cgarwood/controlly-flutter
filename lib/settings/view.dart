import 'package:flutter/material.dart';

import 'package:controlly/settings/model.dart';

final Map configItems = {
  'haUrl': {'type': 'text', 'name': 'Home Assistant URL', 'description': 'URL to your Home Assistant instance'},
  'snapcastUrl': {
    'type': 'text',
    'name': 'Snapcast Server Address',
    'description': 'IP or hostname to your Snapcast server'
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
            return ListTile(
                title: Text(configItem['name']),
                subtitle: Text(settingsManager.getItem(key) ?? ''),
                enabled: true,
                onTap: () => {_showConfigDialog(key)});
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
                initialValue: settingsManager.getItem(key) ?? '');
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
                  //settingsManager.setItem(key, );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
