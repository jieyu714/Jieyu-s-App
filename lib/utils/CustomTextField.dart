import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focus;
  final bool obscureText;
  final int? maxLength;
  final Function? onSubmitted;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText = "",
    required this.controller,
    this.focus,
    this.obscureText = false,
    this.maxLength,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focus,
          obscureText: _isObscured,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            labelText: widget.labelText,
            floatingLabelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: widget.obscureText ? _buildPasswordVisibilityIcon() : null,
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
          onSubmitted: (value) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!();
            }
          },
        ),
        ?widget.hintText.isNotEmpty ? Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            widget.hintText,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          )
        ) : null
      ],
    );
  }

  Widget _buildPasswordVisibilityIcon() {
    return IconButton(
      icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
      color: Colors.grey,
      onPressed: () {
        setState(() {
          _isObscured = !_isObscured;
        });
      },
    );
  }
}