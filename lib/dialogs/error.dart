import 'package:controlly/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ErrorDialog extends StatefulWidget {
  final String? body;
  final String? title;
  final String? subtitle;
  final String? exception;
  const ErrorDialog({
    Key? key,
    this.body,
    this.title,
    this.subtitle,
    this.exception,
  }) : super(key: key);

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.title ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                    Text(widget.body ?? ''),
                    const SizedBox(height: 16),
                    Text(widget.exception?.toString() ?? '',
                        style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.red)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          });
    });
  }
}
