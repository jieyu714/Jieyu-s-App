import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focus;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final Function? onSubmitted;
  final bool readOnly;
  final Function? onTap;
  final TextInputAction textInputAction;
  final bool isRequird;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText = "",
    required this.controller,
    this.focus,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.textInputAction = TextInputAction.done,
    this.isRequird = false
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
          readOnly: widget.readOnly,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            label: widget.isRequird
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: widget.labelText),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red
                        )
                      )
                    ]
                  )
              ) : Text(widget.labelText),
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
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
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