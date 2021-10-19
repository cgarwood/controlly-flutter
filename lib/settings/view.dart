import 'package:flutter/material.dart';

import 'package:controlly/settings/model.dart';

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
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(children: <Widget>[
            TextFormField(
                decoration: const InputDecoration(labelText: "Home Assistant URL"),
                initialValue: settingsManager.haUrl,
                onSaved: (String? value) {
                  // attempt to connect and/or log in
                }),
            TextFormField(
                decoration: const InputDecoration(labelText: "Snapcast Server"),
                initialValue: settingsManager.snapcastUrl,
                onSaved: (String? value) {
                  // attempt to connect and/or log in
                })
          ])),
    );
  }
}
