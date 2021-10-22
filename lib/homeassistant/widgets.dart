import 'dart:async';
import 'package:flutter/material.dart';

import './homeassistant.dart';
import '../internalwidgets/widgets.dart';

List<Widget> buildHomeAssistantEntityTiles(
  HomeAssistant hass, {
  favoritesOnly: false,
  String filter: '',
}) {
  var retval = <Widget>[];
  var entities = hass.entities;
  if (filter.isNotEmpty) {
    entities = entities.where((c) => (c.name + c.id).toLowerCase().contains(filter.toLowerCase())).toList();
  }
  for (var c in entities) if (c.favorite || !favoritesOnly) retval.add(HomeAssistantEntityTile(c));
  return retval;
}

List<Widget> buildHomeAssistantEntityButtons(
  HomeAssistant hass, {
  favoritesOnly: false,
  String filter: '',
}) {
  var retval = <Widget>[];
  var entities = hass.entities;
  if (filter.isNotEmpty) {
    entities = entities.where((c) => (c.name + c.id).toLowerCase().contains(filter.toLowerCase())).toList();
  }
  for (var c in entities) if (c.favorite || !favoritesOnly) retval.add(HomeAssistantEntityButton(entity: c));
  return retval;
}

class HomeAssistantEntityView extends StatefulWidget {
  final HomeAssistant hass;
  final bool showFavorites;
  final bool showAll;
  final bool expandFavorites;
  final bool asGrid;

  HomeAssistantEntityView(
    this.hass, {
    this.showFavorites: true,
    this.showAll: true,
    this.expandFavorites: false,
    this.asGrid: false,
  });

  @override
  _HomeAssistantEntityViewState createState() => _HomeAssistantEntityViewState();
}

class _HomeAssistantEntityViewState extends State<HomeAssistantEntityView> {
  HomeAssistant get hass => widget.hass;
  late StreamSubscription listener;
  late FocusNode focusNode;

  String? _filter;
  String get filter => _filter ?? '';
  set filter(String s) {
    _filter = s;
    refresh();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    filter = '';
    focusNode = FocusNode();
    listener = hass.updates.listen((_) {
      refresh();
    });
    if (!hass.connected) hass.connect();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          child: MyTextInput(
            label: 'Search',
            focusNode: focusNode,
            onChanged: (String s) => filter = s,
            hideInput: false,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: ExpansionPanelList.radio(
                animationDuration: const Duration(milliseconds: 400),
                initialOpenPanelValue: widget.expandFavorites ? 'favorites' : 'all',
                children: <ExpansionPanelRadio>[
                  if (widget.showFavorites)
                    ExpansionPanelRadio(
                      value: 'favorites',
                      headerBuilder: (_, __) => const ListTile(title: Text('Favorites'), dense: true),
                      canTapOnHeader: true,
                      body: widget.asGrid
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: buildHomeAssistantEntityButtons(
                                  hass,
                                  favoritesOnly: true,
                                  filter: filter,
                                ),
                              ),
                            )
                          : Column(
                              children: buildHomeAssistantEntityTiles(
                                hass,
                                favoritesOnly: true,
                                filter: filter,
                              ),
                            ),
                    ),
                  if (widget.showAll)
                    ExpansionPanelRadio(
                      value: 'all',
                      headerBuilder: (_, __) => ListTile(title: Text('All Entities'), dense: true),
                      canTapOnHeader: true,
                      body: widget.asGrid
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: buildHomeAssistantEntityButtons(
                                  hass,
                                  favoritesOnly: false,
                                  filter: filter,
                                ),
                              ),
                            )
                          : Column(
                              children: buildHomeAssistantEntityTiles(
                                hass,
                                favoritesOnly: false,
                                filter: filter,
                              ),
                            ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeAssistantEntityGrid extends StatefulWidget {
  @override
  _HomeAssistantEntityGridState createState() => _HomeAssistantEntityGridState();
}

class _HomeAssistantEntityGridState extends State<HomeAssistantEntityGrid> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HomeAssistantEntityTile extends StatelessWidget {
  final HomeAssistantEntity entity;
  HomeAssistantEntityTile(this.entity);

  @override
  Widget build(BuildContext context) {
    var title = entity.toString();
    return StreamBuilder(
      stream: entity.updates,
      initialData: false,
      builder: (context, snapshot) => ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: (entity is HomeAssistantClimateEntity && (entity as HomeAssistantClimateEntity).fanOn)
                ? Colors.deepOrange
                : null,
          ),
        ),
        subtitle: Text('# ${entity.id}'),
        onTap: () async {
          if (entity is HomeAssistantSwitchEntity) {
            (entity as HomeAssistantSwitchEntity).flipSwitch();
          } else {
            var newEntity =
                await Navigator.of(context).push<HomeAssistantClimateEntity>(MaterialPageRoute(builder: (context) {
              return HomeAssistantClimateEditPage(entity as HomeAssistantClimateEntity);
            }));
            if (newEntity != null) {
              (entity as HomeAssistantClimateEntity).setTemperature(
                newEntity.currentSetTemperature!,
                newEntity.heatMode,
              );
            }
          }
        },
        // onLongPress: () => store.hass.releaseCueList(entity.id),
        selected: entity.isOn,
        leading: (entity is HomeAssistantSwitchEntity)
            ? Switch(
                onChanged: (bool b) => (entity as HomeAssistantSwitchEntity).flipSwitch(b),
                value: entity.isOn,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entity.transitioning)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
            IconButton(
              icon: Icon(
                entity.favorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () => entity.favorite = !entity.favorite,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeAssistantEntityButton extends StatefulWidget {
  final HomeAssistantEntity entity;
  final String? caption;
  final Function? onTap;
  final Image? image;
  final Icon? icon;

  const HomeAssistantEntityButton({
    Key? key,
    required this.entity,
    this.caption,
    this.onTap,
    this.icon,
    this.image,
  }) : super(key: key);

  @override
  _HomeAssistantEntityButtonState createState() => _HomeAssistantEntityButtonState();
}

class _HomeAssistantEntityButtonState extends State<HomeAssistantEntityButton> {
  late StreamSubscription listener;

  HomeAssistantEntity? editing;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    listener = widget.entity.updates.listen((_) => refresh());
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  Color? entityColor() {
    switch (widget.entity.runtimeType) {
      case HomeAssistantClimateEntity:
        return Colors.cyan;
      case HomeAssistantSwitchEntity:
        return Colors.amber;
      case HomeAssistantScriptEntity:
        return Colors.blueAccent;
      default:
        return null;
    }
  }

  Widget entityWidget() {
    switch (widget.entity.runtimeType) {
      case HomeAssistantClimateEntity:
        return HomeAssistantClimateEntityButton(widget.entity as HomeAssistantClimateEntity);
      case HomeAssistantScriptEntity:
        return HomeAssistantSwitchEntityButton(widget.entity as HomeAssistantScriptEntity);
      case HomeAssistantSwitchEntity:
      default:
        return HomeAssistantSwitchEntityButton(widget.entity as HomeAssistantSwitchEntity);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget w;
    switch (widget.entity.runtimeType) {
      case HomeAssistantClimateEntity:
    }
    bool isClimate = (widget.entity is HomeAssistantClimateEntity);
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: 90,
      height: 80,
      child: Material(
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: Container(
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: entityColor() ?? Colors.black,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 50,
                alignment: Alignment.center,
                child: entityWidget(),
              ),
              SizedBox(
                height: 2,
                child: (widget.entity.transitioning) ? const LinearProgressIndicator() : Container(),
              ),
              Container(
                width: double.infinity,
                height: 26,
                margin: const EdgeInsets.only(bottom: 2),
                child: Text(
                  widget.caption ?? widget.entity.name,
                  textAlign: TextAlign.center,
                  // textWidthBasis: TextWidthBasis.parent,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeAssistantClimateEditPage extends StatefulWidget {
  final HomeAssistantClimateEntity entity;

  const HomeAssistantClimateEditPage(this.entity, {Key? key}) : super(key: key);

  @override
  _HomeAssistantClimateEditPageState createState() => _HomeAssistantClimateEditPageState();
}

class _HomeAssistantClimateEditPageState extends State<HomeAssistantClimateEditPage> {
  // private fields for editing
  late HomeAssistantFanMode _mode;
  late HomeAssistantHeatMode _heatMode;
  int _newTemp = 0;
  bool _isOn = false;
  List<FocusNode> nodes = [];

  String get heatModeString => _heatMode == HomeAssistantHeatMode.heat ? 'HEAT' : 'COOL';

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.entity.fanMode;
    _newTemp = widget.entity.currentSetTemperature ?? 0;
    _isOn = widget.entity.fanOn;
    _heatMode = widget.entity.heatMode;
    for (var i = 0; i < 3; i++) {
      nodes.add(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entity.name)),
      body: ListView(
        children: <Widget>[
          // current temperature
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              widget.entity.currentTemperature.toString(),
              style: TextStyle(fontSize: 100),
            ),
          ),
          // set temperature
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 30),
            child: MyTextInput(
              label: 'Set New Temperature',
              initialValue: _newTemp.toString(),
              focusNode: nodes[0],
              // nextNode: nodes[1],
              keyboardType: TextInputType.numberWithOptions(),
              onChanged: (String s) {
                _newTemp = int.tryParse(s.trim()) ?? _newTemp;
              },
            ),
          ),
          // fan on or off
          SwitchListTile(
            value: _mode == HomeAssistantFanMode.forcedOn,
            title: Text('Fan Mode: $_mode'),
            subtitle: Text('Currently: ${_isOn ? 'on' : 'off'}'),
            onChanged: (bool b) {
              _mode = b ? HomeAssistantFanMode.forcedOn : HomeAssistantFanMode.auto;
              refresh();
            },
          ),
          // fan on or off
          SwitchListTile(
            value: _heatMode == HomeAssistantHeatMode.heat,
            title: Text('Will $heatModeString to $_newTemp'),
            subtitle: Text(''),
            onChanged: (bool b) {
              _heatMode = b ? HomeAssistantHeatMode.heat : HomeAssistantHeatMode.cool;
              refresh();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                child: Text('SAVE'),
                onPressed: () {
                  widget.entity.fanMode = _mode;
                  widget.entity.currentSetTemperature = _newTemp;
                  widget.entity.heatMode = _heatMode;
                  Navigator.of(context).pop(widget.entity);
                },
              ),
            ],
          ),
          // hvac mode
          // MyTextInput(),
        ],
      ),
    );
  }
}

class HomeAssistantClimateEntityButton extends StatefulWidget {
  final HomeAssistantClimateEntity entity;
  const HomeAssistantClimateEntityButton(this.entity, {Key? key}) : super(key: key);

  @override
  _HomeAssistantClimateEntityButtonState createState() => _HomeAssistantClimateEntityButtonState();
}

class _HomeAssistantClimateEntityButtonState extends State<HomeAssistantClimateEntityButton> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var entity = await Navigator.of(context).push<HomeAssistantClimateEntity>(MaterialPageRoute(builder: (context) {
          return HomeAssistantClimateEditPage(widget.entity);
        }));
        if (entity != null && entity.currentSetTemperature != null) {
          entity.setTemperature(entity.currentSetTemperature!);
        }
        refresh();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${widget.entity.currentTemperature ?? 0}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.entity.fanOn ? Colors.deepOrange : null,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ' (${widget.entity.currentSetTemperature ?? 0}) ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.entity.fanOn ? Colors.deepOrange : null,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeAssistantSwitchEntityButton extends StatefulWidget {
  final HomeAssistantSwitchEntity entity;
  HomeAssistantSwitchEntityButton(this.entity);
  @override
  _HomeAssistantSwitchEntityButtonState createState() => _HomeAssistantSwitchEntityButtonState();
}

class _HomeAssistantSwitchEntityButtonState extends State<HomeAssistantSwitchEntityButton> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      onChanged: (bool b) => setState(() => widget.entity.flipSwitch(b)),
      value: widget.entity.isOn,
    );
  }
}
