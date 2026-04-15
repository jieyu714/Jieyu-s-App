import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String labelText;
  final String hintText;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final IconData? icon;
  final String Function(T)? itemLabelBuilder;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    this.hintText = "",
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.icon,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            label: isRequired
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: labelText),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                : Text(labelText),
            prefixIcon: icon != null ? Icon(icon) : null,
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2
              ),
            ),
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabelBuilder != null
                  ? itemLabelBuilder!(item)
                  : item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        if (hintText.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              hintText,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}