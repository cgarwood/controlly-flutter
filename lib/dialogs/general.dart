import 'package:controlly/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GeneralDialog extends StatefulWidget {
  final Widget? header;
  final Widget? body;
  final String? title;
  final String? subtitle;
  const GeneralDialog({
    Key? key,
    this.header,
    this.body,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  _GeneralDialogState createState() => _GeneralDialogState();
}

class _GeneralDialogState extends State<GeneralDialog> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder(
          stream: store.ha!.updates,
          builder: (context, snapshot) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(24),
                width: 550,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        widget.header ??
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(widget.title ?? '',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text(widget.subtitle ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            ]),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    widget.body ?? Container(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          });
    });
  }
}
