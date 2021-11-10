import 'package:flutter/material.dart';

mixin EasyRebuild<T extends StatefulWidget> on State<T> {
  void rebuild() {
    if (mounted) setState(() {});
  }
}

class MyTextInput extends StatefulWidget {
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final String? label;
  final String? hintText;
  final bool hideInput;
  final TextCapitalization capitalization;
  final TextInputType keyboardType;
  final String initialValue;
  final bool monospace;
  final bool autoselect;

  const MyTextInput({
    Key? key,
    this.onChanged,
    this.focusNode,
    this.nextNode,
    this.label,
    this.hintText,
    this.hideInput = false,
    this.capitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.initialValue = '',
    this.monospace = false,
    this.autoselect = false,
  }) : super(key: key);

  @override
  _MyTextInputState createState() => _MyTextInputState();
}

class _MyTextInputState extends State<MyTextInput> {
  late String value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    _controller = TextEditingController(text: value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: widget.monospace ? const TextStyle(fontFamily: 'monospace') : null,
      controller: _controller,
      focusNode: widget.focusNode,
      textCapitalization: widget.capitalization,
      decoration: InputDecoration(labelText: widget.label, hintText: widget.hintText),
      keyboardType: widget.keyboardType,
      textInputAction: (widget.nextNode == null) ? TextInputAction.done : TextInputAction.next,
      obscureText: widget.hideInput,
      onTap: () => widget.autoselect
          ? _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length)
          : null,
      onChanged: widget.onChanged,
      onEditingComplete: () {
        if (widget.nextNode != null) {
          widget.nextNode!.requestFocus();
        } else {
          widget.focusNode?.unfocus();
        }
      },
    );
  }
}
