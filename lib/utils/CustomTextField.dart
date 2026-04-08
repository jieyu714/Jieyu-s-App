import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final String? regExp;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.regExp,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
      inputFormatters: [
        if (regExp != null)
          FilteringTextInputFormatter.allow(RegExp(regExp!)),
        if (maxLength != null)
          LengthLimitingTextInputFormatter(maxLength),
      ]
    );
  }
}