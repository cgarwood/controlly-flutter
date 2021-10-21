import 'dart:async';
import 'package:flutter/material.dart';
import './homeassistant.dart';

class HomeAssistantPage extends StatefulWidget {
  final HomeAssistant hass;
  const HomeAssistantPage(this.hass, {Key? key}) : super(key: key);

  @override
  _HomeAssistantPageState createState() => _HomeAssistantPageState();
}

class _HomeAssistantPageState extends State<HomeAssistantPage> {
  late StreamSubscription listener;
  HomeAssistant get hass => widget.hass;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    listener = hass.updates.listen((_) => refresh());
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Assistant Entities'),
      ),
      body: HomeAssistantEntityView(hass, asGrid: false),
    );
  }
}

class HassAuthConfirm extends StatefulWidget {
  final HomeAssistant hass;
  final Uri response;

  const HassAuthConfirm(this.hass, this.response, {Key? key}) : super(key: key);

  @override
  _HassAuthConfirmState createState() => _HassAuthConfirmState();
}

class _HassAuthConfirmState extends State<HassAuthConfirm> {
  bool finishing = true;

  @override
  void initState() {
    super.initState();
    var code = widget.response.queryParameters['code'];
    if (code == null) return;
    widget.hass.getTokens(code).then((_) {
      if (mounted) {
        setState(() {
          finishing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeAssistant Authentication'),
      ),
      body: Center(child: finishing ? const CircularProgressIndicator() : const Text('Confirmed')),
    );
  }
}
