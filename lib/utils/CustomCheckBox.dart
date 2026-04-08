import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  final CustomCheckBoxController? controller;
  final String label;
  final double size;

  const CustomCheckBox({
    super.key,
    required this.controller,
    this.label = "",
    this.size = 20
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.controller!.isChecked,
          onChanged: (value) {
            widget.controller?.isChecked = value!;
          }
        ),
        Expanded(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.size,
              color: Colors.grey[600],
            ),
          ),
        )
      ]
    );
  }
}

class CustomCheckBoxController extends ChangeNotifier {
  bool _isChecked;

  CustomCheckBoxController({bool initValue = false}) : _isChecked = initValue;

  bool get isChecked => _isChecked;

  set isChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  void toggle() {
    _isChecked = !_isChecked;
    notifyListeners();
  }
}