import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yaml/yaml.dart';
import 'package:controlly/utils/helpers.dart';

class CommonTileWidget extends StatefulWidget {
  final HomeAssistantEntity entity;
  final YamlMap config;
  final Widget child;
  final Function? onTap;
  final Function? onLongPress;
  final Function? onRightTap;
  const CommonTileWidget({
    Key? key,
    required this.entity,
    required this.config,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onRightTap,
  }) : super(key: key);

  @override
  _CommonTileWidgetState createState() => _CommonTileWidgetState();
}

class _CommonTileWidgetState extends State<CommonTileWidget> {
  HomeAssistantEntity get entity => widget.entity;
  YamlMap get config => widget.config;

  Color get backgroundColor {
    return getBackgroundColor(entity, config);
  }

  @override
  Widget build(BuildContext context) {
    Widget clickableChild = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: widget.child,
        ),
      ),
    );
    Widget child = Padding(
      padding: const EdgeInsets.all(8),
      child: widget.child,
    );
    bool clickable = widget.onTap != null || widget.onLongPress != null || widget.onRightTap != null;
    return Card(
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        child: clickable ? clickableChild : child,
      ),
    );
  }
}
