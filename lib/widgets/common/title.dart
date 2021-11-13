import 'package:controlly/homeassistant/entity.dart';
import 'package:controlly/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yaml/yaml.dart';

class CommonTitleWidget extends StatefulWidget {
  final HomeAssistantEntity entity;
  final YamlMap config;
  final String textColor;
  final String? subtitleColor;
  final String? defaultSubtitle;
  const CommonTitleWidget(
      {Key? key,
      required this.entity,
      required this.config,
      this.textColor = 'light',
      this.subtitleColor,
      this.defaultSubtitle})
      : super(key: key);

  @override
  _CommonTitleWidgetState createState() => _CommonTitleWidgetState();
}

class _CommonTitleWidgetState extends State<CommonTitleWidget> {
  HomeAssistantEntity get entity => widget.entity;
  YamlMap get config => widget.config;
  Color get titleColor {
    if (widget.textColor == 'light') {
      return Colors.white;
    }
    if (widget.textColor == 'dark') {
      return Colors.black;
    }
    return widget.textColor.toColor();
  }

  Color get subtitleColor {
    if (widget.subtitleColor == null) {
      if (widget.textColor.startsWith('#')) {
        return widget.textColor.toColor();
      }
      if (widget.textColor == 'light') {
        return Colors.white;
      }
      if (widget.textColor == 'dark') {
        return Colors.grey[600]!;
      }
    }
    return widget.subtitleColor!.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          config['title'] ?? entity.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: titleColor,
          ),
        ),
        Text(
          config['subtitle'] ??
              widget.defaultSubtitle ??
              entity.deviceClass?.toTitleCase() ??
              entity.domain.toTitleCase(),
          style: TextStyle(fontSize: 10, color: subtitleColor),
        ),
      ],
    );
  }
}
